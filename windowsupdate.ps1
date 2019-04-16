############################################################################
#                         Windows Update Tool                              #
#                      Created by Ben Richardson                           #
#                            Version 1.2                                   #
#                             19/06/2018                                   #
############################################################################



##Pre-requisites##

##Install NuGet as the package provider
Install-PackageProvider -Name NuGet -Force

##Set PSGallery as a trusted source
Set-PSRepository -name psgallery -InstallationPolicy Trusted

##Install PSWindowsUpdate from PSGallery
Install-module pswindowsupdate -Force

##Import PSWindowsUpdate module to use
Import-module pswindowsupdate

##Menu Options##
Function show-menu
{
    param (
        [string]$title = "Windows Update Menu"
    )
    Write-Host Both options to check will prompt to install afterwards
    Write-Host "1: Press '1' to Check for Windows updates from local WSUS Server."
    Write-Host "2: Press '2' to Check for Windows updates from Microsoft."
    Write-Host "Q: Press 'Q' to exit the script."
}



###Option 1###
##Check for Windows updates from local WSUS Server
Function WSUS-updates-Check
{
Get-WindowsUpdate 
Write-Host ""
$WSUSInstallPrompt = Read-Host "Would you like to install these updates?"
switch ($WSUSInstallPrompt)
	{
 'y' 	{
 WSUS-updates-Install
		}
 'n' 	{
 Write-Host Now Exiting
 exit
		}
	}
}

###Option 2###
##Check for Windows updates from Microsoft##
Function Microsoft-Update-Check
{
Get-WindowsUpdate -MicrosoftUpdate
Write-Host ""
$MicrosoftUpdatePrompt = Read-Host "Would you like to install these updates from Microsoft?"
switch ($MicrosoftUpdatePrompt)
	{
'y' 	{
Microsoft-Update-Install
		}
'n' 	{
Write-Host Now Exiting
exiting
		}
	}
}

###Option 3###
##Install updates from local WSUS Server##
Function WSUS-updates-Install
{
Get-WindowsUpdate -AcceptAll -Install 
}

###Option 4###
##Install updates from Microsoft##
Function Microsoft-Update-Install
{
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install
}




Clear-Host
show-menu -Title "Windows Update Menu"
$selection = Read-Host "Please make a selection to continue"
switch ($selection)
{
    '1' {
        WSUS-updates-Check
    }
    '2' {
        Microsoft-Update-Check
    }
    'Q' {
        Write-Host "Now exiting" -ForegroundColor Yellow
        exit
    }
}
