<#
.SYNOPSIS
    Menu-driven wrapper around the PSWindowsUpdate module.

.DESCRIPTION
    Checks for and installs Windows updates either from the machine's configured
    default update source (WSUS, if one is set by policy) or from Microsoft Update.

    On first run the script installs the PSWindowsUpdate module (and the NuGet
    package provider if needed). Everything shown on screen is also written to a
    transcript log.

.PARAMETER UpdateModule
    Update PSWindowsUpdate from the PowerShell Gallery before showing the menu.
    Off by default so the script starts quickly and works without internet access.

.PARAMETER LogDirectory
    Folder for transcript logs. Created if it does not exist.

.EXAMPLE
    .\windowsupdate.ps1

.EXAMPLE
    .\windowsupdate.ps1 -UpdateModule -LogDirectory D:\Logs\Patching

.NOTES
    Author:       Ben Richardson
    Version:      2.0.0
    Last updated: 06-10-2026
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [switch]$UpdateModule,

    [string]$LogDirectory = (Join-Path $env:ProgramData 'WindowsUpdateTool\Logs')
)

# Service ID Windows uses for Microsoft Update (as opposed to Windows Update / WSUS).
$MicrosoftUpdateServiceId = '7971f918-a847-4430-9279-4a52d1efe18d'


#region Prerequisites

function Initialize-Prerequisite {
    <#
    .SYNOPSIS
        Makes sure PSWindowsUpdate is installed and imported.
    #>
    [CmdletBinding()]
    param (
        [switch]$UpdateModule
    )

    # Older builds (Server 2016 and earlier defaults) cannot reach the gallery without TLS 1.2.
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host 'PSWindowsUpdate module missing. Installing now...'

        # NuGet is only needed to install from the gallery, so only touch it here.
        if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
            Write-Host 'NuGet package provider missing. Installing now...'
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        }

        # -Force skips the untrusted-repository prompt without permanently trusting PSGallery.
        Install-Module -Name PSWindowsUpdate -Force
    }
    elseif ($UpdateModule) {
        Write-Host 'Updating PSWindowsUpdate module...'
        Update-Module -Name PSWindowsUpdate -Force
    }

    Import-Module -Name PSWindowsUpdate -ErrorAction Stop
}

#endregion Prerequisites


#region Helpers

function Confirm-Action {
    <#
    .SYNOPSIS
        Asks a y/n question. Returns $true only for an answer starting with "y".
    #>
    param (
        [Parameter(Mandatory)]
        [string]$Prompt
    )

    (Read-Host "$Prompt (y/n)") -match '^\s*y'
}

function Register-MicrosoftUpdateService {
    <#
    .SYNOPSIS
        Registers the Microsoft Update service if this machine has never opted in.
    #>
    $registered = Get-WUServiceManager | Where-Object { $_.ServiceID -eq $MicrosoftUpdateServiceId }

    if (-not $registered) {
        Write-Host 'Microsoft Update service not registered. Registering now...'
        Add-WUServiceManager -MicrosoftUpdate -Confirm:$false | Out-Null
    }
}

function Invoke-Update {
    <#
    .SYNOPSIS
        Single entry point for every scan/install combination in the menu.

    .PARAMETER Microsoft
        Use Microsoft Update instead of the machine's default source.

    .PARAMETER Install
        Download and install everything found, without per-update prompts.

    .PARAMETER AutoReboot
        Reboot automatically if an installed update requires it.
    #>
    [CmdletBinding()]
    param (
        [switch]$Microsoft,
        [switch]$Install,
        [switch]$AutoReboot
    )

    $params = @{ Verbose = $true }

    if ($Microsoft) {
        Register-MicrosoftUpdateService
        $params.MicrosoftUpdate = $true
    }
    if ($Install) {
        $params.Install   = $true
        $params.AcceptAll = $true
    }
    if ($AutoReboot) {
        $params.AutoReboot = $true
    }

    Get-WindowsUpdate @params
}

function Invoke-UpdateCheck {
    <#
    .SYNOPSIS
        Lists available updates, then offers to install them.
    #>
    [CmdletBinding()]
    param (
        [switch]$Microsoft
    )

    $updates = Invoke-Update -Microsoft:$Microsoft

    if (-not $updates) {
        Write-Host 'No updates available.' -ForegroundColor Green
        return
    }

    $updates | Out-Host
    Write-Host ''

    if (Confirm-Action 'Would you like to install these updates?') {
        Invoke-Update -Microsoft:$Microsoft -Install | Out-Host
    }
}

function Invoke-UpdateWithReboot {
    <#
    .SYNOPSIS
        Installs updates and reboots automatically, after an explicit confirmation.
    #>
    [CmdletBinding()]
    param (
        [switch]$Microsoft
    )

    Write-Host ''
    Write-Host "This will automatically RESTART $env:COMPUTERNAME if an update requires it." -ForegroundColor Red -BackgroundColor Black

    if (Confirm-Action 'Continue?') {
        Invoke-Update -Microsoft:$Microsoft -Install -AutoReboot | Out-Host
    }
    else {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
    }
}

function Show-Menu {
    param (
        [string]$Title = 'Windows Update Menu'
    )

    $rebootWarning = 'WARNING! This option auto reboots the current computer/server'

    Clear-Host
    Write-Host "===== $Title ($env:COMPUTERNAME) =====" -ForegroundColor Cyan
    Write-Host 'Note: "default source" is WSUS if this machine is pointed at one by policy, otherwise Windows Update.'
    Write-Host 'Note: both Check options offer to install afterwards.' -ForegroundColor Green
    Write-Host ''
    Write-Host '1: Check for updates from the default source.'
    Write-Host '2: Check for updates from Microsoft.'
    Write-Host '3: Install updates from the default source.'
    Write-Host '4: Install updates from the default source and reboot. ' -NoNewline
    Write-Host $rebootWarning -ForegroundColor Red -BackgroundColor Black
    Write-Host '5: Install updates from Microsoft.'
    Write-Host '6: Install updates from Microsoft and reboot. ' -NoNewline
    Write-Host $rebootWarning -ForegroundColor Red -BackgroundColor Black
    Write-Host 'Q: Quit.'
    Write-Host ''
}

#endregion Helpers


#region Main

if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $LogDirectory ('WindowsUpdate_{0:yyyy-MM-dd_HHmmss}.log' -f (Get-Date))
Start-Transcript -Path $logFile | Out-Null

try {
    try {
        Initialize-Prerequisite -UpdateModule:$UpdateModule -ErrorAction Stop
    }
    catch {
        Write-Host "Could not prepare PSWindowsUpdate: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    do {
        Show-Menu
        $selection = (Read-Host 'Please make a selection').Trim()

        try {
            switch ($selection) {
                '1' { Invoke-UpdateCheck }
                '2' { Invoke-UpdateCheck -Microsoft }
                '3' { Invoke-Update -Install | Out-Host }
                '4' { Invoke-UpdateWithReboot }
                '5' { Invoke-Update -Microsoft -Install | Out-Host }
                '6' { Invoke-UpdateWithReboot -Microsoft }
                'q' { Write-Host 'Now exiting.' -ForegroundColor Yellow }
                default { Write-Host "'$selection' is not a valid option." -ForegroundColor Yellow }
            }
        }
        catch {
            # Keep the menu alive if a scan or install fails (e.g. source unreachable).
            Write-Host "Operation failed: $($_.Exception.Message)" -ForegroundColor Red
        }

        if ($selection -ne 'q') {
            Write-Host ''
            Read-Host 'Press Enter to return to the menu' | Out-Null
        }
    } until ($selection -eq 'q')
}
finally {
    Stop-Transcript | Out-Null
    Write-Host "Log saved to $logFile"
}

#endregion Main
