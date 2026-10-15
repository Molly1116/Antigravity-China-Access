Option Explicit

Dim shell, fileSystem, env, powershellExe, scriptPath, configPath, launchCommand

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")
Set env = shell.Environment("Process")

' Keep the launcher silent; the PowerShell process is also process-scoped.
powershellExe = shell.ExpandEnvironmentStrings("%WINDIR%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
scriptPath = fileSystem.BuildPath(fileSystem.GetParentFolderName(WScript.ScriptFullName), "Start-Antigravity-Proxy.ps1")
configPath = fileSystem.BuildPath(fileSystem.GetParentFolderName(WScript.ScriptFullName), "proxy-config.psd1")

If Not fileSystem.FileExists(scriptPath) Then
  WScript.Quit 2
End If

launchCommand = Chr(34) & powershellExe & Chr(34) & _
  " -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File " & _
  Chr(34) & scriptPath & Chr(34)

If fileSystem.FileExists(configPath) Then
  launchCommand = launchCommand & " -ProxyConfigPath " & Chr(34) & configPath & Chr(34)
End If

shell.Run launchCommand, 0, False

Set env = Nothing
Set fileSystem = Nothing
Set shell = Nothing

