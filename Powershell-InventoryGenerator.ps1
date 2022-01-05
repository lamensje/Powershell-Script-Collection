# Store computer info in variable
$Computerinfo = Get-ComputerInfo

$Date = Get-Date -UFormat %Y.%m.%d
$WorkingDirectory = "\\fs1\Logs$\Inventarisatie"
$DailyReport = "$WorkingDirectory\daily\Inventarisatie_" + $Date + ".csv"
$Report = "$WorkingDirectory\Inventarisatie.csv"
$ReportTemp = "$env:temp\Inventarisatie.csv"

# Check if computer already exists in inventory, skips otherwise
$ExistsDaily = Get-Content -Path $DailyReport -ErrorAction SilentlyContinue | Select-String -Pattern $env:computername

# Stores domain name without .local
$Domain = ($computerinfo.CsDomain -split "\.") | Select-Object -First 1

# Organizational Unit in Domain, last folfer name
$OU = (([adsisearcher]"(&(name=$env:computername)(objectClass=computer))").findall().path -Split "," | Select-String "OU" | Select-Object -First 1) -Split "=" | Select-Object -Last 1

# First in the list connected (status Up) Physical network interface with the highest ifIndex
$adapter = Get-NetAdapter -Physical | Where-Object Status -Like "Up" | Sort-Object ifIndex -Descending | Select-Object -First 1

# Use motherboard model number instead of SKU if not OEM
$PCModel = "Unknown"
if ($Computerinfo.CsSystemSKUNumber.ToString() -eq "To Be Filled By O.E.M." -or $Computerinfo.CsSystemSKUNumber.ToString() -like "*Default*") {$PCModel = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS -Name BaseBoardProduct | Select-Object -ExpandProperty BaseBoardProduct)} else {$PCModel = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS -Name SystemProductName | Select-Object -ExpandProperty SystemProductName) + " (" + $Computerinfo.CsSystemSKUNumber.ToString() + ")"}

# BIOS type (Legacy / UEFI), version and release date
$BIOS = $Computerinfo.BiosSMBIOSBIOSVersion.ToString() + " (" + $Computerinfo.BiosFirmwareType.ToString() + ")" 

# Windows version (Home / Pro for exmaple) and version (21H2 for exmaple)
$OS = $Computerinfo.OsName.ToString() + " " + (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion | Select-Object -ExpandProperty DisplayVersion).ToString() -replace "Microsoft Windows ","W" -replace "Insider Preview ",""

# CPU name + count
$CPU = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0 -Name ProcessorNameString | Select-Object -ExpandProperty ProcessorNameString) -replace "\s+ ",""
if ($Computerinfo.CsNumberOfProcessors -ge 2) {$CPU += (" (x" + $Computerinfo.CsNumberOfProcessors.Tostring() + ")")}

# RAM amount, config and speed
$TotalRAM = ($Computerinfo.CsPhyicallyInstalledMemory / 1mb).ToString()
$RAMSpeed = Get-WmiObject CIM_physicalmemory | Select-Object -first 1 -ExpandProperty Speed
Get-WmiObject CIM_physicalmemory | Where-Object DeviceLocator -NotLike "*ROM*" | Select-Object Capacity | ForEach-Object -Begin {$RAMconfig = "("} -Process {$RAMconfig += (($_.Capacity / 1GB).Tostring() + "+")} -End {$RAMconfig = $RAMconfig.TrimEnd('+'); $RAMconfig += ")"}
$RAM = $TotalRAM.ToString() +"GB "+ $RAMSpeed.ToString() +"MT/s " + $RAMconfig

# GPU names
$GPU = $null
Get-WmiObject CIM_VideoController | Select-Object Name | ForEach-Object {$GPU += ($_.Name + " + ")} -End {$GPU = $GPU.TrimEnd(' + ')}

# Disks name, Bus type (Sata / NVMe) and type (HDD / SSD)
$Disks = $null
Get-PhysicalDisk | Where-Object BusType -NotLike "USB" | Select FriendlyName, MediaType, BusType | ForEach-Object -Process {$Disks += $_.FriendlyName + " (" + $_.BusType + " " + $_.MediaType + ") + "} -End {$Disks = $Disks.TrimEnd(' + ')}

# Boot (C:\) drive free space in GB
$DiskFree = ([math]::Round((Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }| Select-Object -ExpandProperty FreeSpace) / 1gb)).Tostring() + "GB"

# Read Office verison
$ospp = $null
$x32 = ${env:ProgramFiles(x86)} + "\Microsoft Office"
$x64 = $env:ProgramFiles + "\Microsoft Office"

if (Test-Path -Path $x32) {$Excel32 = Get-ChildItem -Recurse -Path $x32 -Filter "EXCEL.EXE"}
if (Test-Path -Path $x64) {$Excel64 = Get-ChildItem -Recurse -Path $x64 -Filter "EXCEL.EXE"}
if ($Excel32) {$Excel = $Excel32; $ospp = $x32 + "\Office16\OSPP.VBS"}
if ($Excel64) {$Excel = $Excel64; $ospp = $x64 + "\Office16\OSPP.VBS"}
$DisplayVersion = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -Name "DisplayVersion" -ErrorAction SilentlyContinue | Where-Object {$_.DisplayVersion -eq ($Excel.VersionInfo.ProductVersion | Select-Object -First 1) -and $_.PSChildName -notlike "{*}"}
$OfficeVerision = $null
Get-ItemProperty -Path $DisplayVersion.PSPath | ForEach-Object {$OfficeVerision += ($_.PSChildName + " v" + $_.DisplayVersion + $(if ($_.InstallLocation -eq $x32) {" (32 Bit)"} else {" (64 Bit) "})); $OfficeVerision += ($_.Name + "+ ")} -End {$OfficeVerision = $OfficeVerision.TrimEnd(',+ ')}

# Office Licence
$OfficeLicence = (cscript $ospp /dstatus)

if (($OfficeLicence | Select-String "LICENSED") -ne $null) {
	$OfficeParsed = (($OfficeLicence | Select-String "LICENSED" -Context 1) -split "`n" | Select-String -NotMatch "EXPIRATION") -split ": " | Select-String -NotMatch "STATUS", "key"
	$OfficeKey = $OfficeParsed[1].ToString()
	$OfficeLicenceStatus = ($OfficeParsed[0] -split "---")[1].ToString()
} else {
	$OfficeLicenceStatus = $null
	$OfficeKey = ((($OfficeLicence | Select-String "Last*") -Split ":" | Select-String -NotMatch "Last*")[0].ToString() + (($OfficeLicence | Select-String "STATUS*") -Split ":" | Select-String -NotMatch "STATUS*")[0].ToString())
}

# Userprofile list, removing occasional domain name after username (in the most complicated way possible, probably)
$Profiles = $null
Get-ChildItem -Path "C:\Users" | Where-Object Name -NotLike "Public" | Where-Object Name -NotLike "testuser" | Where-Object Name -NotLike "Administrator" | Where-Object Name -NotLike "localadmin" | Select-Object Name | ForEach-Object {if ($_.Name -Like ("*" + $Domain)) {$_.Name = $_.Name.Substring(0,$_.Name.Length-($Domain.Length+1))}; $Profiles += ($_.Name + ", ")} -End {$Profiles = $Profiles.TrimEnd(', ')}

# Filling object with collected data
$specs =[pscustomobject]@{
	'Gebruiker' = $env:username
	'PC Naam' = $env:computername
	'Locatie' = $OU
	'Mac-Address' = $adapter.MacAddress
	'Link Speed' = $adapter.LinkSpeed
	'PC Model' = $PCModel
	'BIOS' = $BIOS		
	'Besturingssysteem' = $OS
	'Processor' = $CPU
	'Werkgeheugen' = $RAM
	'Videokaart' = $GPU
	'Schijf Model' = $Disks
	'Vrije ruimte opstartschijf' = $DiskFree
	'Profielen op schijf' = $Profiles
	'Office Versie' = $OfficeVerision
	'Office Status' = $OfficeLicenceStatus
	'Office Key' = $OfficeKey
	'Laatste update' = $Date
}	

if ($ExistsDaily -eq $null){
	# Exporting specs to daily inventory
    $specs | Export-CSV $DailyReport -Append -NoTypeInformation -Force -Delimiter ";" 
}

# Remove existing inventory entry
$inventory = get-content -Path $Report -ErrorAction SilentlyContinue | select-string -pattern $env:computername -notmatch
Set-Content $ReportTemp $inventory

# Export inventory with up-to-date information
$specs | Export-CSV $ReportTemp -Append -NoTypeInformation -Force -Delimiter ";"

# Sort inventory by PC Name, not a one-liner, doesn't work
$inventorySorted = Import-Csv $ReportTemp -Delimiter ";" | sort-object "PC Naam" 
$inventorySorted | Export-Csv $ReportTemp -NoTypeInformation -Force -Delimiter ";"

# Remove " and empty lines
$ReportClean = ((Get-Content $ReportTemp) -Replace "`"","") | ? {$_.trim() -ne ""}
Set-Content $Report $ReportClean
