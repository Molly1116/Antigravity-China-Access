# Google Antigravity China Mainland Network Access Solution

This project provides a process-scoped proxy launcher for Google Antigravity on Windows.

It is intended for users in mainland China who encounter situations such as:

- Antigravity opens, but sign-in, models, or the Agent cannot connect;
- the Electron UI can reach the network while the Language Server or Agent cannot;
- Global Mode is not desired;
- TUN is not desired;
- persistent Windows environment variables or whole-machine proxy settings should remain unchanged.

This is not a Chinese localization project and not a proxy implementation. It provides a separate launcher that temporarily injects HTTP proxy environment variables into the Antigravity process tree.

> Important: This project does not remove Google regional restrictions, bypass account eligibility checks, or guarantee that every request will be proxied successfully. It only addresses components that support the relevant proxy environment variables. Check applicable service, account, network, and legal requirements yourself.

## 1. How it works

The launch chain is:

```text
Desktop shortcut
    -> wscript.exe (hidden)
    -> Start-Antigravity-Proxy.vbs
    -> Start-Antigravity-Proxy.ps1
    -> official Antigravity.lnk or official Antigravity.exe
    -> Antigravity child processes inherit the proxy environment
```

The PowerShell launcher sets these variables in its own process environment:

```text
HTTP_PROXY=http://127.0.0.1:10808
HTTPS_PROXY=http://127.0.0.1:10808
http_proxy=http://127.0.0.1:10808
https_proxy=http://127.0.0.1:10808
NO_PROXY=localhost,127.0.0.1,::1
no_proxy=localhost,127.0.0.1,::1
```

It then starts the official Antigravity entry point. Windows child processes normally inherit the parent environment, so Language Server, Agent, and network libraries that honor `HTTP_PROXY` / `HTTPS_PROXY` can use the local proxy.

The variables exist only in this launch chain:

- no `setx` is used;
- User and System environment variables are not written;
- WinINET is not changed;
- WinHTTP is not changed;
- registry, routes, DNS, TUN, and v2rayN settings are not changed;
- the Antigravity installation directory is not modified.

Components that ignore these variables may still connect directly. This project does not intercept all traffic.

## 2. Difference from Global Mode and TUN

| Item | This project | Global Mode | TUN |
| --- | --- | --- | --- |
| Scope | Antigravity launch process tree | Usually the proxy client's global routing scope | Traffic captured by a virtual adapter |
| Whole-system network changes | No | May affect the system | Changes routing/network-stack behavior |
| Persistent environment changes | No | Usually not required | Usually not required |
| Effect on other applications | Should not affect unrelated processes | May affect them | May affect them |
| Dependency | Application/network-library support for HTTP proxy variables | Proxy-client rules | TUN driver and routes |

The goal is:

```text
Antigravity process tree -> 127.0.0.1:10808 -> local proxy
```

not:

```text
Entire Windows system -> VPN / Global Mode
```

## 3. Requirements

1. Windows 10 or Windows 11.
2. Google Antigravity installed.
3. A local HTTP proxy listener.
4. The listener must accept HTTP `CONNECT` requests.

For example, a v2rayN Mixed/HTTP listener may be:

```text
http://127.0.0.1:10808
```

If your local listener is pure SOCKS5, use an HTTP/Mixed entry provided by the proxy client. Do not put a `socks5://` URL in `ProxyUrl` unless you have confirmed that the target network library supports it.

## 4. Configure the proxy address and port

Copy the example configuration:

```powershell
Copy-Item .\proxy-config.example.psd1 .\proxy-config.psd1
```

Edit `proxy-config.psd1`:

```powershell
@{
    ProxyUrl = 'http://127.0.0.1:10808'
    NoProxy = 'localhost,127.0.0.1,::1'
}
```

Only `ProxyUrl` normally needs to change. A local unauthenticated listener is recommended. Do not commit proxy credentials or tokens to GitHub.

If `proxy-config.psd1` is absent, the launcher uses `http://127.0.0.1:10808` as its default.

## 5. Install the project

Download a Release archive or clone the repository:

```powershell
git clone https://github.com/<your-account>/Antigravity-China-Access.git
Set-Location .\Antigravity-China-Access
```

Copy and edit the configuration:

```powershell
Copy-Item .\proxy-config.example.psd1 .\proxy-config.psd1
notepad .\proxy-config.psd1
```

No Go, Node.js, Python, or third-party runtime is required. The scripts use Windows PowerShell, Windows Script Host, and the Windows Shell shortcut interface.

## 6. Create a desktop shortcut

Run this from the project directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\New-Antigravity-ProxyShortcut.ps1
```

The default shortcut is:

```text
Desktop\Antigravity (Proxy).lnk
```

The script refuses to overwrite an existing shortcut. The shortcut targets hidden `wscript.exe`, and uses the official `Antigravity.exe` icon when available.

## 7. Start Antigravity with one click

Double-click:

```text
Antigravity (Proxy).lnk
```

No long-running black console window is shown. Antigravity still uses its official installation files and official user-data directory.

You can also run the launcher directly:

```powershell
wscript.exe //B //NoLogo .\Start-Antigravity-Proxy.vbs
```

## 8. Return to normal startup

Do not uninstall the proxy client. Start Antigravity from the Windows Start menu or the original official shortcut.

Normal startup does not use this project's process-local environment variables.

## 9. Uninstall

1. Delete `Antigravity (Proxy).lnk` from the desktop.
2. Delete this project directory if it is no longer needed.
3. Do not delete the official Antigravity installation directory.

This project creates no service, scheduled task, startup item, or system-wide environment variable.

## 10. Recheck after Antigravity updates

An Antigravity update can change its installation path, official shortcut behavior, or child-process proxy inheritance. After an update:

1. confirm that the local proxy listener is still available;
2. start Antigravity from the dedicated shortcut;
3. check the UI, sign-in, model list, and Agent;
4. if it fails, check whether the Language Server still inherits the proxy variables.

Do not switch to whole-machine Global Mode or TUN just because an update fails. First identify which process changed its network behavior.

## 11. Known limitations and troubleshooting

### Antigravity still cannot connect

- confirm that the local proxy listener is running;
- confirm that `ProxyUrl` uses `http://`, not a pure SOCKS5 URL;
- confirm that the port is not used by another process;
- confirm that Antigravity is installed in the default location;
- confirm that the failing component honors `HTTP_PROXY` / `HTTPS_PROXY`.

### Why can the UI connect while the Agent fails?

Electron UI, Language Server, and Agent may be separate processes. A UI using WinINET or its own network settings does not imply that child services inherit the same proxy. This project places the environment variables in the official launch chain's parent process.

### Does this proxy all traffic?

No. It only affects processes that inherit the variables and network libraries that honor them. Components that ignore them, independent services, other applications, and system services are outside the guarantee.

### Can proxy credentials leak?

The example configuration contains no credentials. Do not publish URLs containing usernames/passwords, tokens, cookies, logs, or personal paths.

### Is this a regional-restriction bypass tool?

No. It is a process-scoped HTTP proxy launcher. It does not change account eligibility or guarantee service availability.

## 12. Validation scope

The implementation is based on a method used successfully on the author's personal Windows setup. On that setup, Antigravity GUI, Language Server, bundled Agent, and a real model request were verified through the local HTTP proxy.

The public generic version has not been independently tested across devices. Behavior can vary with Antigravity versions, installation paths, proxy clients, and network libraries.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).

