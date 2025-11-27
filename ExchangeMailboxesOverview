# stores all mailboxes in variable
$mailboxes = Get-Mailbox -ResultSize unlimited | Select-Object DisplayName, UserPrincipalName, RecipientTypeDetails, Database, @{L="EmailAddresses";E={$e = $_.EmailAddresses -notlike "x500*";[string]::join(";", ($e))}}, Guid | Sort-Object Name

# Displays all mailbox types
#$mailboxes | Select-Object -Unique RecipientTypeDetails

# Sort mailboxes
$userMailboxes = $mailboxes | Where-Object RecipientTypeDetails -eq UserMailbox
$discoveryMailbox = $mailboxes | Where-Object RecipientTypeDetails -eq DiscoveryMailbox
$roomMailbox = $mailboxes | Where-Object RecipientTypeDetails -eq RoomMailbox
$sharedMailbox = $mailboxes | Where-Object RecipientTypeDetails -eq SharedMailbox

$publicFolders = Get-PublicFolder -Recurse -ResultSize unlimited | Select-Object Name, Identity, MailEnabled, @{L="EmailAddresses";E={$null}}, @{L="CreationTime";E={$null}}, @{L="TotalItemSize";E={$null}}, @{L="ItemCount";E={$null}}, EntryId

$publicFolders | ForEach-Object {
	$stats = Get-PublicFolderStatistics $_.Identity
	$_.CreationTime = $stats.LastModificationTime
	$_.ItemCount = $stats.ItemCount
	$count = $_.Identity.MapiFolderPath | Measure-Object | Select-Object -ExpandProperty Count
	$path = $null
	for ($i = 0; $i -le $count; $i++) {
		$path += ("\" + $_.Identity.MapiFolderPath[$i])
		$publicFolders | Where-Object Identity -like "$path" | ForEach-Object {$_.TotalItemSize += $stats.TotalItemSize.ToMB()}
	}
	Write-Host $_.Identity.MapiFolderPath.ToString() -Fore White
}

$publicFolderOverview = $publicFolders | Where-Object {(($_.Identity.MapiFolderPath | Measure-Object | Select-Object -ExpandProperty Count) -le 2)} | Select-Object Identity, @{L="TotalItemSize";E={([Math]::Round(($_.TotalItemSize / 1000),1)).ToString() + "GB"}}

$mailPublicFolders = Get-MailPublicFolder -ResultSize unlimited | Select-Object DisplayName, @{L="EmailAddresses";E={[string]::join(";", ($_.EmailAddresses))}}, EntryId

$mailPublicFolders | ForEach-Object {
	$EntryId = $_.EntryId
	$EmailAddresses = $_.EmailAddresses
	$publicFolders | Where-Object EntryId -eq $EntryId | ForEach-Object {$_.EmailAddresses = $EmailAddresses}
}

# Exports
$exportFolder = "C:\Users\administrator\Documents"
$userMailboxes | Export-CSV "$exportFolder\userMailboxes.csv" -NoTypeInformation -Force -Delimiter ";" 
$discoveryMailbox | Export-CSV "$exportFolder\discoveryMailbox.csv" -NoTypeInformation -Force -Delimiter ";" 
$roomMailbox | Export-CSV "$exportFolder\roomMailbox.csv" -NoTypeInformation -Force -Delimiter ";" 
$sharedMailbox | Export-CSV "$exportFolder\sharedMailbox.csv" -NoTypeInformation -Force -Delimiter ";" 
$publicFolders | Export-CSV "$exportFolder\publicFolders.csv" -NoTypeInformation -Force -Delimiter ";" 
$publicFolderOverview | Export-CSV "$exportFolder\publicFolderOverview.csv" -NoTypeInformation -Force -Delimiter ";" 
