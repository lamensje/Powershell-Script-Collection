$Domain = '192.168.0.0'
$Plum = "\\$Domain\Profiles$\$env:username.V6\Sticky Notes 10\plum.sqlite"
$StickyNotesRemote = "\\$Domain\Profiles$\$env:username.V6\Sticky Notes 10"
$StickyNotesLocal = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
$PlumExist = [System.IO.File]::Exists($Plum)
$ProcessActive = Get-Process Microsoft.Notes -ErrorAction SilentlyContinue
if ($PlumExist) {
    if ($ProcessActive)
    {
        Stop-Process -Name Microsoft.Notes
        robocopy $StickyNotesRemote $StickyNotesLocal /mir
        C:\Windows\explorer.exe shell:AppsFolder\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe!App
    }
    else {
        robocopy $StickyNotesRemote $StickyNotesLocal /mir
    }
}
