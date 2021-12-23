# AddPrinters

Temporairly allows driver installation to user, adds printer with driver, then restricts printer driver installation to administrators again for security.

# CleanupExchangeLogs

Cleans up Exchange server 2013 logs (plus inetpub) older than 7 weeks to free up some space
- DailyPerformanceLogs
- HttpProxy
- Ews
- RPC Client Access
- MailboxAssistantsLog
- RpcHttp
- inetpub

# Powershell-InventoryGenerator

Automatically generates a .CSV file containing computer information after this powershell script is deployed to run on each machine.
I'm new to powershell, this code is quite messy but it works. Take what you need.

Currently reads out (in Dutch names):
- Windows username
- Windows PC name
- Ethernet MAC Address
- Ethernet link speed
- PC model number
- BIOS version and type
- Windows version
- CPU(s) name
- RAM amount, speed and layout
- GPU(s)
- Disk model name
- Boot disk free
- Userprofiles on disk
- Installed Office version name
- Office last 5 digits of key and status 
