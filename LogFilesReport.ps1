# Example logfile input:
# LOGOUT testuser di 21-12-2021  8:30:24,67 DOMAIN-PC-036 
# LOGIN  testuser2 fr 21-12-2021 16:36:45,28 DOMAIN-PC-094  


$Path = '\\fs1\Logs$'
$Output = '\\fs1\Logs$\Inventarisatie\gebruikersoverzicht.html'

Get-ChildItem $Path | Where-Object LastWriteTime -gt (Get-Date).AddDays(-7) | Where-Object name -Like "*.log" | ForEach-Object {Get-Content $_.VersionInfo.FileName -Tail 1} | Foreach-Object {
	$Split = $_ -split '(?=\b )' 
	
	$Gebruiker = $Split | Select-Object -Index 1
	$Computer = $Split | Select-Object -Last 2 | Select-Object -First 1
	$Actie = $Split | Select-Object -First 1
	$Tijd = ($Split | Select-Object -Last 3 | Select-Object -First 1) -split "," | Select-Object -First 1
	$Datum = $Split | Select-Object -Last 4 | Select-Object -First 1

	$specs =[pscustomobject]@{
		'Gebruiker' = $Gebruiker
		'PC Naam' = $Computer
		'Actie' = $Actie
		'Tijd' = $Tijd
		'Datum' = $Datum
	}
	$specs
} | Out-HtmlView -filepath $Output -PreventShowHTML -Title "Gebruikersoverzicht" -DisablePaging -PreContent {"<h1>Laatst gewijzigd: $(Get-Date)</h1>"}
