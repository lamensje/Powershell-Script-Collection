$Outlook = $null
$x32 = ${env:ProgramFiles(x86)} + "\Microsoft Office\root\Office16"
$x64 = $env:ProgramFiles + "\Microsoft Office\root\Office16"
	
if (Test-Path -Path $x32) {$Outlook = Get-ChildItem -Path $x32 -Filter "OUTLOOK.EXE"}
if (Test-Path -Path $x64) {$Outlook = Get-ChildItem -Path $x64 -Filter "OUTLOOK.EXE"}
	
if ($Outlook -ne $null) {
	$WshShell = New-Object -comObject WScript.Shell
	$ShortcutStartMenu = $WshShell.CreateShortcut("C:\Users\" + $env:username + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Outlook.lnk")
	$ShortcutStartMenu.TargetPath = $Outlook.VersionInfo.FileName
	$ShortcutStartMenu.Save()
	$WshShell = $null
}