# pswindowsupdate-tool

A menu-driven PowerShell wrapper around the [PSWindowsUpdate](https://www.powershellgallery.com/packages/PSWindowsUpdate) module. It lets you check for and install Windows updates from a console, without using the Windows Update settings app.

Updates can come from either:

- **The default source** - whatever the machine is configured to use. This is your WSUS server if policy points the machine at one, otherwise Windows Update.
- **Microsoft Update** - directly from Microsoft, bypassing WSUS.

## Requirements

- Windows PowerShell 5.1 or later
- An elevated (Run as administrator) session
- Internet access to the PowerShell Gallery on first run, to install PSWindowsUpdate (and the NuGet provider if it is missing)

## Usage

```powershell
.\windowsupdate.ps1
```

| Option | Action |
| ------ | ------ |
| 1 | Check for updates from the default source, then offer to install |
| 2 | Check for updates from Microsoft, then offer to install |
| 3 | Install updates from the default source |
| 4 | Install updates from the default source and **reboot automatically** |
| 5 | Install updates from Microsoft |
| 6 | Install updates from Microsoft and **reboot automatically** |
| Q | Quit |

Options 4 and 6 ask for confirmation before doing anything. The menu returns after each action.

### Parameters

| Parameter | Description |
| --------- | ----------- |
| `-UpdateModule` | Update PSWindowsUpdate from the PowerShell Gallery before showing the menu. Off by default. |
| `-LogDirectory` | Folder for transcript logs. Defaults to `C:\ProgramData\WindowsUpdateTool\Logs`. |

```powershell
.\windowsupdate.ps1 -UpdateModule -LogDirectory D:\Logs\Patching
```

## Notes

- Every run writes a transcript log to the log directory.
- The Microsoft options register the Microsoft Update service on the machine if it has never been opted in.# pswindowsupdate-tool

This powershell file allows you to easily update a windows based computer (without the need to use the built-in horrible new windows 10 windows update settings tool)
You can update from a local WSUS server if you have a policy already defined for this or directly from Microsoft.

There are options to:
Check for updates (from Microsoft)
Check for updates (from your local WSUS server)
Install updates (from Microsoft)
Install updates (from your local WSUS server)
And lastly auto update (which install and reboots if required) again from both local or Microsoft.
