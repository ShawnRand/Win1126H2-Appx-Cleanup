# Windows Appx Cleanup

[Remove-WindowsAppxApps.ps1](./Remove-WindowsAppxApps.ps1) removes selected Windows Appx apps for **all existing users** and removes their provisioning so they are not automatically installed for **new users**.

App selection is configured directly in the script. No JSON configuration or external dependencies are required beyond the Windows Appx and DISM cmdlets.

> **Warning:** This changes the running Windows installation and affects other users on the device. Review the selections, test on a disposable device, and preview with `-WhatIf` before proceeding. There is no automatic rollback.

## Requirements

- Windows with the Appx and DISM PowerShell cmdlets available.
- **64-bit Windows PowerShell 5.1**, started with **Run as administrator**.
- PowerShell 7 and 32-bit PowerShell hosts are not supported.
- An execution policy that permits running the script under your organization's policies.

These requirements also apply when using `-ListApps` or `-WhatIf`.

## Default selections

The following Appx identities are enabled for removal in the supplied script:

| Appx identity |
| --- |
| `Clipchamp.Clipchamp` |
| `Microsoft.BingNews` |
| `Microsoft.BingSearch` |
| `Microsoft.BingWeather` |
| `Microsoft.GamingApp` |
| `Microsoft.MicrosoftSolitaireCollection` |
| `Microsoft.Xbox.TCUI` |
| `Microsoft.XboxGamingOverlay` |
| `Microsoft.XboxIdentityProvider` |
| `Microsoft.XboxSpeechToTextOverlay` |
| `Microsoft.YourPhone` |
| `Microsoft.ZuneMusic` |
| `MSTeams` |

All other entries in the supplied list are set to keep. A selected app that is not installed or provisioned is reported as `AlreadyAbsent`.

## Configure app selection

Edit the `$AppsToRemove` ordered hashtable near the top of [Remove-WindowsAppxApps.ps1](./Remove-WindowsAppxApps.ps1):

```powershell
"Clipchamp.Clipchamp" = $true   # Request removal
"Microsoft.WindowsCalculator" = $false   # Keep
```

- `$true` requests removal; `$false` leaves the app unchanged.
- Use exact Appx identities, not friendly display names, full versioned package names, or wildcard patterns.
- Use Boolean values (`$true` or `$false`), not quoted strings.
- Use `-ListApps` to discover identities on the device. Discovered apps not already in the source list are not selected; add an exact-name entry if needed.
- Protected components cannot be removed by setting their entry to `$true`.

## Usage

Open an elevated, 64-bit **Windows PowerShell** session and change to the directory containing the script.

### 1. Inspect inventory and protections

```powershell
.\Remove-WindowsAppxApps.ps1 -ListApps |
    Format-Table Name, Remove, InstalledForExistingUsers, ProvisionedForNewUsers, Protected -AutoSize
```

For detailed protection reasons:

```powershell
.\Remove-WindowsAppxApps.ps1 -ListApps |
    Where-Object Protected |
    Format-List Name, ProtectionReason
```

`-ListApps` returns objects containing `Name`, `InSourceList`, `Remove`, `InstalledForExistingUsers`, `ProvisionedForNewUsers`, `Protected`, and `ProtectionReason`. It does not remove packages or write a removal log.

### 2. Preview the request

```powershell
.\Remove-WindowsAppxApps.ps1 -WhatIf
```

This validates selections, checks protections, and previews the overall removal request without removing packages or creating the removal log. It does not simulate individual uninstall operations or guarantee that a real removal will succeed. Result statuses remain `NotRequested`.

### 3. Remove selected apps

```powershell
.\Remove-WindowsAppxApps.ps1
```

The script requests confirmation before starting. After reviewing and testing the selections, confirmation can be suppressed for unattended execution:

```powershell
.\Remove-WindowsAppxApps.ps1 -Confirm:$false
```

To use a custom log location:

```powershell
.\Remove-WindowsAppxApps.ps1 -LogPath 'C:\Logs\AppxRemoval.log'
```

## Parameters

| Parameter | Description |
| --- | --- |
| `-ListApps` | Lists configured and discovered identities, their selection state, presence, and protection reasons; exits without removal. |
| `-LogPath <string>` | Sets the log file path. Defaults to `%ProgramData%\21stTSC\AppxRemoval\AppxRemoval.log`. |
| `-WhatIf` | Previews the overall removal request without making changes. |
| `-Confirm` | Controls the confirmation prompt. Use `-Confirm:$false` to suppress it. |

`-WhatIf` and `-Confirm` are PowerShell common parameters supported by the script.

## Removal behavior and safeguards

Before any removal, the script inventories installed and provisioned packages and validates all configured entries. If any selected identity is protected, the entire run stops before removing any apps. If nothing is selected, it warns and exits without changes.

Protection checks block:

- Packages Windows marks as non-removable.
- Framework packages and resource-only packages.
- Packages installed under the Windows `SystemApps` directory.
- Dependencies of currently installed packages.
- Explicitly protected Windows, Store, installer, security, Edge, and runtime identities.

For each allowed selection, the script:

1. Removes matching provisioning from the running Windows installation.
2. Removes registered packages for all users, processing bundles before their contained main packages.
3. Checks that no matching registered/staged or provisioned packages remain.
4. Emits a per-app result and logs progress and errors.

Protection depends partly on the device's current inventory. A default selection may be blocked on a particular device; review `ProtectionReason` and set that selection to `$false` before retrying.

## Results and logging

Each selected app produces an object with:

| Field | Meaning |
| --- | --- |
| `Name` | Exact Appx identity. |
| `Status` | `NotRequested`, `Removed`, `AlreadyAbsent`, or `Failed`. |
| `RegisteredPackagesRemoved` | Number of successful registered-package removal calls. |
| `ProvisionedPackagesRemoved` | Number of successful provisioning removal calls. |
| `RestartNeeded` | Whether a provisioning removal reported that a restart is needed. |
| `ErrorMessage` | Details of removal or verification failures, when present. |

`NotRequested` also applies when the confirmation prompt is declined. Removal counts are package-operation counts, not counts of affected users.

The log directory is created after confirmation, and timestamped messages are appended to the log file. The script also writes progress messages to the console.

Individual removal errors are recorded while processing continues where possible. If any selected app fails, the script throws a terminating error after processing the selections. **A failed run can leave partial changes**: successful removals are not rolled back.

## Limitations and recovery

- This script targets Appx packages, not traditional Win32/MSI applications or Windows optional features.
- It operates on the running Windows installation, not an offline image.
- It does not automatically reboot. Review `RestartNeeded` and restart manually when appropriate.
- It does not include backup, reinstall, or rollback functionality. Recovery may require reinstalling apps from an appropriate source or restoring a system backup.
- It does not enforce a permanent removal policy; later installations, servicing, or management policies may restore apps.
- If removal fails, review the log and per-app errors, resolve the reported issue, and rerun. Apps already absent are handled without requesting their removal again.
