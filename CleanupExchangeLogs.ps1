# Rename Title Window
$host.ui.RawUI.WindowTitle = "Clean Exchange Log Files"

Function Cleanup {
    # Set Date for Log
    $LogDate = Get-Date -Format "MM-d-yy-HHmm"
	
	# Set Deletion Date for Recent Items
    $RecentItemsDate = (Get-Date).AddDays(-3)

    # Define log file location
    $Cleanuplog = "$env:USERPROFILE\Cleanup$LogDate.log"

    # Start Logging
    Start-Transcript -Path "$CleanupLog"

    # Begin!
    Write-Host -ForegroundColor Green "Beginning Script...`n"

    # Delete all files from DailyPerformanceLogs folder
    $DailyPerformanceLogs = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\Diagnostics\DailyPerformanceLogs"
    if (Test-Path "$DailyPerformanceLogs") {
        Write-Host -ForegroundColor Yellow "Deleting all files from " + $DailyPerformanceLogs + "`n"
        $OldFiles = Get-ChildItem -Path $DailyPerformanceLogs -Recurse -File -ErrorAction SilentlyContinue | Where-Object Extension -Like ".blg"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$DailyPerformanceLogs\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from Logging HttpProxy folder
    $HttpProxy = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\HttpProxy"
    if (Test-Path "$HttpProxy") {
        Write-Host -ForegroundColor Yellow "Deleting files older than " + $RecentItemsDate + " from " + $HttpProxy + "`n"
        $OldFiles = Get-ChildItem -Path $HttpProxy -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".LOG"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$HttpProxy\Eas\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$HttpProxy\Ews\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$HttpProxy\Owa\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$HttpProxy\Autodiscover\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$HttpProxy\RpcHttp\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$HttpProxyS\Oab\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from Ews folder
    $Ews = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\Ews"
    if (Test-Path "$Ews") {
        Write-Host -ForegroundColor Yellow "Deleting all files older than " + $RecentItemsDate + " from " + $Ews + "`n"
        $OldFiles = Get-ChildItem -Path $Ews -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".LOG"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$Ews\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from RPC folder
    $RPC = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\RPC Client Access"
    if (Test-Path "$RPC") {
        Write-Host -ForegroundColor Yellow "Deleting all files older than " + $RecentItemsDate + " from " + $RPC + "`n"
        $OldFiles = Get-ChildItem -Path $RPC -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".LOG"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$RPC\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from MailboxAssistantsLog folder
    $MailboxAssistantsLog = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\MailboxAssistantsLog"
    if (Test-Path "$MailboxAssistantsLog") {
        Write-Host -ForegroundColor Yellow "Deleting all files older than " + $RecentItemsDate + " from " + $MailboxAssistantsLog + "`n"
        $OldFiles = Get-ChildItem -Path $MailboxAssistantsLog -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".LOG"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$MailboxAssistantsLog\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from RpcHttp folder
    $RpcHttp = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\RpcHttp"
    if (Test-Path "$RpcHttp") {
        Write-Host -ForegroundColor Yellow "Deleting all files older than " + $RecentItemsDate + " from " + $RpcHttp + "`n"
        $OldFiles = Get-ChildItem -Path $RpcHttp -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".LOG"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$RpcHttp\W3SVC1\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$RpcHttp\W3SVC2\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from inetpub folder
    $inetpub = "C:\inetpub\logs\LogFiles"
    if (Test-Path "$inetpub") {
        Write-Host -ForegroundColor Yellow "Deleting all files older than " + $RecentItemsDate + " from " + $inetpub + "`n"
        $OldFiles = Get-ChildItem -Path $inetpub -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".LOG"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$inetpub\W3SVC1\$file" -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$inetpub\W3SVC2\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Read some of the output before going away
    ###Start-Sleep -s 15

    # Completed Successfully!
    # Open Log File
    ###Invoke-Item $Cleanuplog

    # Stop Script
    Stop-Transcript
}

Cleanup
