# Store computer info in variable
$Computerinfo = Get-ComputerInfo

$Date = Get-Date -UFormat %Y.%m.%d
$Path = "\\fs1\Logs$\Inventarisatie_" + $Date + ".csv"

# Check if computer already exists in inventory, skips otherwise
$Exists = Get-Content -Path $Path -ErrorAction SilentlyContinue | Select-String -Pattern $env:computername 

if ($Exists -eq $null){
	
	# First in the list connected (status Up) Physical network interface
	$adapter = Get-NetAdapter -Physical | Where-Object Status -Like "Up" | Select-Object -First 1
	
	# Use motherboard model number instead of SKU if not OEM
	$PCModel = "Unknown"
	if ($Computerinfo.CsSystemSKUNumber.ToString() -eq "To Be Filled By O.E.M.") {$PCModel = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS -Name BaseBoardProduct | Select-Object -ExpandProperty BaseBoardProduct)} else {$PCModel = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS -Name SystemProductName | Select-Object -ExpandProperty SystemProductName) + " (" + $Computerinfo.CsSystemSKUNumber.ToString() + ")"}
	
	# BIOS type (Legacy / UEFI), version and release date
	$BIOS = $Computerinfo.BiosSMBIOSBIOSVersion.ToString() + " (" + $Computerinfo.BiosFirmwareType.ToString() + ")" 
	
	# Windows version (Home / Pro for exmaple) and version (21H2 for exmaple)
	$OS = $Computerinfo.OsName.ToString() + " " + (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion | Select-Object -ExpandProperty DisplayVersion).ToString()

	# CPU name
	$CPU = Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0 -Name ProcessorNameString | Select-Object -ExpandProperty ProcessorNameString

	# RAM amount, Dual-channel or Single-Channel and speed
	$TotalRAM = ($Computerinfo.CsPhyicallyInstalledMemory / 1mb).ToString() + "GB"
	$RAMSpeed = Get-WmiObject CIM_physicalmemory | Select-Object -first 1 -ExpandProperty Speed
	if ((Get-WmiObject CIM_physicalmemory | Select-Object -ExpandProperty Speed).Count -ge 2){$RAMChannel = "Dual-Channel"} else {$RAMChannel = "Single-Channel"}
	$RAM = $TotalRAM.ToString() +"GB "+ $RAMSpeed.ToString() +"MT/s " + $RAMChannel

	# Primary GPU name
	$GPU = Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinSAT" -Name PrimaryAdapterString | Select-Object -ExpandProperty PrimaryAdapterString

	# Disks name, Bus type (Sata / NVMe) and type (HDD / SSD)
	$Disks = $null
	Get-PhysicalDisk | Select FriendlyName, MediaType, BusType | ForEach-Object -Process {$Disks += $_.FriendlyName + " " + $_.BusType + " " + $_.MediaType + " "}

	# Boot drive free space in GB
	$DiskFree = ([math]::Round((Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object -ExpandProperty FreeSpace) / 1gb)).Tostring() + "GB"
	
	# Read Office verison
	$ospp = $null
	$x32 = ${env:ProgramFiles(x86)} + "\Microsoft Office"
	$x64 = $env:ProgramFiles + "\Microsoft Office"

	if (Test-Path -Path $x32) {$Excel32 = Get-ChildItem -Recurse -Path $x32 -Filter "EXCEL.EXE"}
	if (Test-Path -Path $x64) {$Excel64 = Get-ChildItem -Recurse -Path $x64 -Filter "EXCEL.EXE"}
	if ($Excel32) {$Excel = $Excel32; $ospp = $x32 + "\Office16\OSPP.VBS"}
	if ($Excel64) {$Excel = $Excel64; $ospp = $x64 + "\Office16\OSPP.VBS"}
	$DisplayVersion = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -Name "DisplayVersion" -ErrorAction SilentlyContinue | Where-Object {$_.DisplayVersion -eq $Excel.VersionInfo.ProductVersion -and $_.PSChildName -notlike "{*}"}
	$OfficeVerision = $null
	Get-ItemProperty -Path $DisplayVersion.PSPath | ForEach-Object {$OfficeVerision += ($_.PSChildName + " v" + $_.DisplayVersion + $(if ($_.InstallLocation -eq $x32) {" 32 Bit"} else {" 64 Bit "}))}

	# Office Licence
	$OfficeLicenceStatus = (cscript $ospp /dstatus)
	$OfficeKey = ((($OfficeLicenceStatus | Select-String "Last*") -Split ":" | Select-String -NotMatch "Last*") | Select-Object -First 1).ToString() + ((($OfficeLicenceStatus | Select-String "STATUS*") -Split ":" | Select-String -NotMatch "STATUS*") | Select-Object -First 1).ToString()

	# Userprofile list
	$ProfileList = $null
	$Profiles = Get-ChildItem -Path "C:\Users" | Select-Object Name | Where-Object Name -NotLike "Public" | Where-Object Name -NotLike "testuser" | Where-Object Name -NotLike "Administrator" | Where-Object Name -NotLike "localadmin"
	foreach ($profile in $Profiles) {
		$ProfileList += ($profile.Name + " ")
	}
	

	# Filling object with collected data
	$specs =[pscustomobject]@{
		'Gebruiker' = $env:username
		'PC Naam' = $env:computername
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
		'Profielen op schijf' = $ProfileList
		'Office versie' = $OfficeVerision
		'Office Licentie' = $OfficeKey
    }
	
	# Exporting object to CSV, opened with Excel
    $specs | Export-CSV $Path -Append -NoTypeInformation -Force
}
