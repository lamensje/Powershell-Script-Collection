I'm new to powershell, so expect this code is possibly quite messy and inefficient. Take what you need.
Some scripts generate output in Dutch, most comments and variables are in English though.

# AddPrinters

Temporairly allows driver installation to user, adds printer with driver, then restricts printer driver installation to administrators again for security.

# CleanupExchangeLogs

Cleans up Exchange server 2013 logs (plus inetpub) older than 7 weeks to free up some space.
- DailyPerformanceLogs
- HttpProxy
- Ews
- RPC Client Access
- MailboxAssistantsLog
- RpcHttp
- inetpub

# LogFilesReport

Reads last line in .log files in specific folder, parses specific string and creates an HTML overview.
Currently used to create an overview on what computer a user has logged in, with timestamp.

# Powershell-InventoryGenerator

Automatically generates a .CSV file containing computer information after this powershell script is deployed to run on each machine.

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

# SickyNotesRoamingSync

Makes Sticy Notes from the windows 10 App sync between computers using the roaming profile directory.
Set as script during user logon and logoff using GPO.

# SilentSoftwareDeployStartup

Silently installs software in the background. 
Also works as GPO Computer startup script.
