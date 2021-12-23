 reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
 net stop spooler
 net start spooler
 
 Add-Printer -ConnectionName "\\FILESERVER\PRINTERNAME"

 Remove-Printer -Name "Fax"
 Remove-Printer -Name "Send To OneNote 2016"
 Remove-Printer -Name "Microsoft XPS Document Writer"
 
 reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 1 /f
