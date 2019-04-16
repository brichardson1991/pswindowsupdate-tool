############################################################################
#                         Windows Update Tool                              #
#                      Created by Ben Richardson                           #
#                            Version 1.4                                   #
#                             05/02/2019                                   #
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
    Write-Host Please Note: Both options to check will prompt to install afterwards
    Write-Host "1: Press '1' to Check for Windows updates from local WSUS Server."
    Write-Host "2: Press '2' to Check for Windows updates from Microsoft."
    Write-Host "3: Press '3' to Install Windows updates from your local WSUS Server."
    Write-Host "4: Press '4' to Auto Install Windows updates from your local WSUS Server." "WARNING! This option auto reboots the current computer/server" -ForegroundColor red -BackgroundColor black
    Write-Host "5: Press '5' to Install Windows updates from Microsoft."
    Write-Host "6: Press '6' to Auto Install Windows updates from Microsoft." "WARNING! This option auto reboots the current computer/server" -ForegroundColor red -BackgroundColor black
    Write-Host "Q: Press 'Q' to exit the script."
}


###Option 1###
##Check for Windows updates from local WSUS Server
Function WSUS-updates-Check
{
	Get-WindowsUpdate -Verbose
	Write-Host ""
	$WSUSInstallPrompt = Read-Host "Would you like to install these updates?"
	switch ($WSUSInstallPrompt)
	{
		'y' 
			{
				WSUS-updates-Install
			}
		'n' 	
			{
				Write-Host "Now Exiting" -ForegroundColor Yellow -BackgroundColor Black
				exit
			}
	}
}

###Option 2###
##Check for Windows updates from Microsoft##
Function Microsoft-Update-Check
{
	Get-WindowsUpdate -MicrosoftUpdate -Verbose
	Write-Host ""
	$MicrosoftUpdatePrompt = Read-Host "Would you like to install these updates from Microsoft?"
	switch ($MicrosoftUpdatePrompt)
	{
		'y' 	
			{
				Microsoft-Update-Install
			}
		'n' 	
			{
				Write-Host "Now Exiting" -ForegroundColor Yellow -BackgroundColor Black
				exiting
			}
	}
}

###Option 3###
##Install updates from local WSUS Server##
Function WSUS-updates-Install
{
	Get-WindowsUpdate -AcceptAll -Install -Verbose
}
	
###Option 4###
##Install updates from local WSUS Server##
Function WSUS-updates-Install-Reboot
{
	Write-Host ""
	$WSUSRebootPrompt = Write-Host "This will Automatically RESTART the current computer/server running this script. By continuing you are agreeing to this" -ForegroundColor Red -BackgroundColor Black
	switch ($WSUSRebootPrompt)
	{
			'y'
				{
				Get-WindowsUpdate -AcceptAll -Install -Verbose -Autoreboot
				}
			'n'
				{
					Write-Host "Now Exiting" -ForegroundColor Yellow -BackgroundColor Black
					exit
				}
			
	}
}

###Option 5###
##Install updates from Microsoft##
Function Microsoft-Update-Install
{
	Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -Verbose
}
	
	
###Option 6###
##Install updates from Microsoft##
Function Microsoft-Update-Install-Reboot
{
	Write-Host ""
	$MicrosoftRebootPrompt = Write-Host "This will Automatically RESTART the current computer/server running this script. By continuing you are agreeing to this" -ForegroundColor Red -BackgroundColor Black
	switch ($MicrosoftRebootPrompt)
	{
		'y'
			{
				Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -Verbose -Autoreboot
			}
		'n'
			{
				Write-Host "Now Exiting" -ForegroundColor Yellow -BackgroundColor Black
				exit
			}
	
	}
}




Clear-Host
show-menu -Title "Windows Update Menu"
$selection = Read-Host "Please make a selection to continue"
switch ($selection)
{
    '1' 
		{
			WSUS-updates-Check
		}
    '2' 
		{
        Microsoft-Update-Check
		}
	'3' 
		{
		WSUS-updates-Install
		}	
	'4' 
		{
		WSUS-updates-Install-Reboot
		}
	'5' 
		{
		Microsoft-Update-Install
		}	
	'6' 
		{
		Microsoft-Update-Install-Reboot
		}
    'Q' 
		{
        Write-Host "Now exiting" -ForegroundColor Yellow -BackgroundColor Black
        exit
		}
}


