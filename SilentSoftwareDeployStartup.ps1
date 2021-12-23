if (!(Test-Path -Path "C:\Program Files\7-Zip")) {Start-Process -Passthru "\\fs1\Packages$\7z1900-x64.exe" /S | Wait-Process -Timeout 20}
