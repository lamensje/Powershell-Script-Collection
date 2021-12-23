$Domain = '192.168.0.0'
$StickyNotesLocal = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite"
$StickyNotesLocalExist = [System.IO.File]::Exists($StickyNotesLocal)
if ($StickyNotesLocalExist) {
	robocopy "C:\Users\$env:username\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState" "\\$Domain\Profiles$\$env:username.V6\Sticky Notes 10" /mir
}
