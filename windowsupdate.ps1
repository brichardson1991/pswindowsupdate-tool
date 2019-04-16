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
    Write-Host Please Note: Both options to check will prompt for install afterwards
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



# SIG # Begin signature block
# MIIFagYJKoZIhvcNAQcCoIIFWzCCBVcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiNb7o3hsTvVgtNy5QR7RRJCj
# jBmgggMGMIIDAjCCAeqgAwIBAgIQYPX0tsPZZr1CxoTkY5bNvzANBgkqhkiG9w0B
# AQUFADAZMRcwFQYDVQQDDA5CZW4gUmljaGFyZHNvbjAeFw0xODA2MTkwOTEzNDRa
# Fw0xOTA2MTkwOTMzNDRaMBkxFzAVBgNVBAMMDkJlbiBSaWNoYXJkc29uMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtGuaKYSukj+V0u5t6tDO8zJm6CA0
# uRUHNZq4yQAk16Fg1e4opuxQHbYjUgzcNhtNzSq6OsneJhuFUUiQTVdzaxXpYg3w
# RuTurRKzIHKGwJk4v0epXQ9z3DWTEo0DfH9ydCV9ImCBRbPgmweliTxek8iMvpzU
# oehmjzBDBhSLwc5/T4elbH5JDm6GkVTveD0vDNGvCBvMDXAPd5PV/p8AKRx3Olef
# wHc7GWdK4z/cTLqMnlIaZUOighTeqliG2DloJZvaP/nhc5myx1+w8sBhOzN60zlz
# HykG9lVr7AUz2mDHlggja2LsgrhAZEPQmDQQ7gallvuguzPoEYUeNb3UhQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFJoMeY4QB7o6bpnEZMLMx1br+UaaMA0GCSqGSIb3DQEBBQUAA4IBAQBlVLhF
# VZHLgKuK7Srwnd5Dl8Gni65zVPmHHHonZln5a1asVCGGQm/VpEJGyxfuDg1huKK1
# gKgXHAREWzbKfg9K0UBJJivdEKujlkYAu2VWZZ31v+MC1n+3EkHBStHoaVtOw1Gc
# EFh03CbWRG5EVr461fyUTvNt/c1PtS9V871XwFiio5VOIZUM/QycMavVYnkTvo+K
# IKfhg+OJ2sNb6mqpTPX0uhZfzI4uBwwfWO5pA+LaFt11M3Yom1wuwYvq17OKOn+p
# Td09yUyZAjReLgKAMKr24rxDmypEYjTYc4rzCF0mBm9muGNRxTEMoG970LY5TDUo
# 21F3L63/NWuUZ+KwMYIBzjCCAcoCAQEwLTAZMRcwFQYDVQQDDA5CZW4gUmljaGFy
# ZHNvbgIQYPX0tsPZZr1CxoTkY5bNvzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUgGfKew17JbxM
# e5f1zIa5dR1YE6kwDQYJKoZIhvcNAQEBBQAEggEAJbFlvLXXNTd5z59voCBpydFL
# oKS4pvXpZGxASRUKsHCMgKw6m1U/mk3UT08FE6xuRVvjdrMJ7ygT2UyiZZKpUWUv
# tZ0ilMDggNORmKByODwkJYW0ypI/vvCy6keFrMs5KLQP9sQeXjHA7HhFlofIK613
# 1IRYtd5zAXPYAg0AUq8xe3Aby8w0/tFHT9C1EvmeMNjcsgcCXBxa0+xpEqbhs5LR
# XkXqqqjgic4HC9niny38i7jOpN0HnlqE3ro8cgRBgeRuDlzyGqekhYGe7UXRfzL/
# HcrvY9supdH73Hq5K0jyE82BA5FEdS6ZelESzPfkhH77Ekhv+UR6YuDiT2OO3A==
# SIG # End signature block
