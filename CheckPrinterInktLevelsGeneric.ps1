Set-Location -Path "P:\0 ict en telefoon\software\snmp" -PassThru
$env:MIBDIRS = "P:\0 ict en telefoon\software\snmp\mibs"

$printers = @{
    'some printer name' = '192.168.0.0'

}

$black = 99999
$cyan = 99999
$magenta = 99999
$yellow = 99999
$drum = 99999
$Status = 99999

$vervangeninkt = @{}
$vervangendrums = @{}
$binnenkortvervangen = @{}

$printers.Keys | % {   
    $black = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.9.1.1  
    $cyan = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.9.1.2
    $magenta = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.9.1.3
    $yellow = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.9.1.4
    $drum = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.8.1.1
    $Status = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.18.1.1.8.1.1

    if ($Status -eq $null) {$Status = 'OID'}

    if ($black.Contains('OID')) {$black = 99999}
    if ($cyan.Contains('OID')) {$cyan = 99999}
    if ($magenta.Contains('OID')) {$magenta = 99999}
    if ($yellow.Contains('OID')) {$yellow = 99999}
    if ($drum.Contains('OID')) {$drum = 99999}
    if ($Status.Contains('OID')) {$Status = 99999}

    if ($black -eq -3) {$black = "Ok"}
    if ($cyan -eq -3) {$cyan = "Ok"}
    if ($magenta -eq -3) {$magenta = "Ok"}
    if ($yellow -eq -3) {$yellow = "Ok"}
    if ($drum -eq -3) {$drum = "Ok"}
    if ($Status -eq 99999 -or "") {$Status = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.16.5.1.2.1.1}

    if ($black -eq -2 -or $black -eq 0) {
        $black = "Leeg"
        $leeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.1
        $vervangeninkt.Add($_ + " Zwart: ",$leeg)}
    if ($cyan -eq -2 -or $cyan -eq 0) {
        $cyan = "Leeg"
        $leeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.2
        if (!($leeg.Contains('Drum'))) {$vervangeninkt.Add($_ + " Cyan: ",$leeg)}}
    if ($magenta -eq -2 -or $magenta -eq 0)  {
        $magenta = "Leeg"
        $leeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.3
        $vervangeninkt.Add($_ + " Magenta: ",$leeg)}
    if ($yellow -eq -2 -or $yellow -eq 0) {
        $yellow = "Leeg"
        $leeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.4
        $vervangeninkt.Add($_ + " Geel: ",$leeg)}
    if ($drum -eq -2 -or $drum -eq 0) {
        $drum = "?"
        $vervangendrums.Add($_ + " Drum: ","?")}
    if ($Status -eq 99999 -or "") {
        $Status = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.18.1.1.8.1.2}

    if ($black -le 20 -and $black -gt 0) {
        $bijnaleeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.1
        $binnenkortvervangen.Add($_ + ": Zwart " + $black + "% ",$bijnaleeg)}
    if ($cyan -le 20 -and $cyan -gt 0) {
        $bijnaleeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.2
        $binnenkortvervangen.Add($_ + ": Cyan " + $cyan + "% ",$bijnaleeg)}
    if ($magenta -le 20 -and $magenta -gt 0)  {
        $bijnaleeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.3
        $binnenkortvervangen.Add($_ + ": Magenta " + $magenta + "% ",$bijnaleeg)}
    if ($yellow -le 20 -and $yellow -gt 0) {
        $bijnaleeg = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.11.1.1.6.1.4
        $binnenkortvervangen.Add($_ + ": Geel " + $yellow + "% ",$bijnaleeg)}

    if ($Status -eq 99999 -or "") {$Status = .\snmpwalk.exe -r1 -v2c -Oq -Ov -c public $printers.Item($_) iso.3.6.1.2.1.43.16.5.1.2.1.1}

    if ($black -eq 99999) {$black = "Niet aanwezig"}
    if ($cyan -eq 99999) {$cyan = "Niet aanwezig"}
    if ($magenta -eq 99999) {$magenta = "Niet aanwezig"}
    if ($yellow -eq 99999) {$yellow = "Niet aanwezig"}
    if ($drum -eq 99999) {$drum = "Niet aanwezig"}
    if ($Status -eq 99999 -or "") {$Status = "Niet aanwezig"}

    if ($black.Trim() -match "^[-]?[0-9.]+$") {$black += "%"}
    if ($cyan.Trim() -match "^[-]?[0-9.]+$") {$cyan += "%"}
    if ($magenta.Trim() -match "^[-]?[0-9.]+$") {$magenta += "%"}
    if ($yellow.Trim() -match "^[-]?[0-9.]+$") {$yellow += "%"}
    if ($drum.Trim() -match "^[-]?[0-9.]+$") {$drum += "%"}


    $printer = [PSCustomObject]@{
        Naam = $_ 
        IP = $printers.Item($_)
        Zwart = $black
        Cyan = $Cyan
        Magenta = $magenta
        Geel = $yellow
        drum = $drum
        Status = $Status
    }
    $printer
}

Write-Host `n
Write-Host "Binnenkort (<20%) te vervangen onderdelen: "
$binnenkortvervangen.Keys | % {Write-Host " - " $_ $binnenkortvervangen.Item($_)}

Write-Host `n

Write-Host "Te vervangen inkt: "
$vervangeninkt.Keys | % {Write-Host " - " $_ $vervangeninkt.Item($_)}

Write-Host `n

Write-Host "Te vervangen drums (mogelijk!): "
$vervangendrums.Keys | % {Write-Host " - " $_ $vervangendrums.Item($_)}

Write-Host `n

pause
