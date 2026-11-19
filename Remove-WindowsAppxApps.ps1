#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.DESCRIPTION
    Edit the AppsToRemove list below: change $false to $true only for desired
    removals. Removes selected apps for all existing users and from provisioning
    for future users. No JSON configuration is used. Core packages are protected.
    Use -ListApps to inspect current app inventory, selections, and protections.
    Run in elevated, 64-bit Windows PowerShell 5.1. Test on a disposable device.
.EXAMPLE
    .\Remove-WindowsAppxApps.ps1 -ListApps
.EXAMPLE
    .\Remove-WindowsAppxApps.ps1 -WhatIf
.EXAMPLE
    .\Remove-WindowsAppxApps.ps1
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
param(
    [switch]$ListApps,

    [ValidateNotNullOrEmpty()]
    [string]$LogPath = (Join-Path $env:ProgramData "ShrandCleanup\AppxRemoval\AppxRemoval.log")
)

# Edit only the values: $false = keep, $true = request removal.
# Protected Windows components remain blocked even if set to $true.
$AppsToRemove = [ordered]@{
    "1527c705-839a-4832-9118-54d4Bd6a0c89" = $false
    "c5e2524a-ea46-4f67-841f-6a9465d9d515" = $false
    "E2A4F912-2574-4A75-9BB0-0D023378592B" = $false
    "F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE" = $false
    "Microsoft.AAD.BrokerPlugin" = $false
    "Microsoft.AccountsControl" = $false
    "Microsoft.AIFabric.CBS.1.6" = $false
    "Microsoft.AsyncTextService" = $false
    "Microsoft.BioEnrollment" = $false
    "Microsoft.CredDialogHost" = $false
    "Microsoft.ECApp" = $false
    "Microsoft.LockApp" = $false
    "Microsoft.MicrosoftEdgeDevToolsClient" = $false
    "Microsoft.UI.Xaml.CBS" = $false
    "Microsoft.Win32WebViewHost" = $false
    "Microsoft.Windows.Apprep.ChxApp" = $false
    "Microsoft.Windows.AssignedAccessLockApp" = $false
    "Microsoft.Windows.AugLoop.CBS" = $false
    "Microsoft.Windows.CapturePicker" = $false
    "Microsoft.Windows.CloudExperienceHost" = $false
    "Microsoft.Windows.ContentDeliveryManager" = $false
    "Microsoft.Windows.NarratorQuickStart" = $false
    "Microsoft.Windows.OOBENetworkCaptivePortal" = $false
    "Microsoft.Windows.OOBENetworkConnectionFlow" = $false
    "Microsoft.Windows.ParentalControls" = $false
    "Microsoft.Windows.PeopleExperienceHost" = $false
    "Microsoft.Windows.PinningConfirmationDialog" = $false
    "Microsoft.Windows.PrintQueueActionCenter" = $false
    "Microsoft.Windows.SecureAssessmentBrowser" = $false
    "Microsoft.Windows.ShellExperienceHost" = $false
    "Microsoft.Windows.StartMenuExperienceHost" = $false
    "Microsoft.Windows.XGpuEjectDialog" = $false
    "Microsoft.WindowsAppRuntime.CBS.1.6" = $false
    "Microsoft.WindowsAppRuntime.CBS.2" = $false
    "Microsoft.XboxGameCallableUI" = $false
    "MicrosoftWindows.61869720.Voiess" = $false
    "MicrosoftWindows.61869721.Livtop" = $false
    "MicrosoftWindows.61869722.Speion" = $false
    "MicrosoftWindows.61869836.InpApp" = $false
    "MicrosoftWindows.Client.CBS" = $false
    "MicrosoftWindows.Client.CoreAI" = $false
    "MicrosoftWindows.Client.Core" = $false
    "MicrosoftWindows.Client.FileExp" = $false
    "MicrosoftWindows.Client.OOBE" = $false
    "MicrosoftWindows.Client.Photon" = $false
    "MicrosoftWindows.UndockedDevKit" = $false
    "Windows.CBSPreview" = $false
    "windows.immersivecontrolpanel" = $false
    "Windows.PrintDialog" = $false
    "Microsoft.WindowsAppRuntime.1.6" = $false
    "Microsoft.NET.Native.Runtime.2.2" = $false
    "Microsoft.NET.Native.Framework.2.2" = $false
    "Microsoft.UI.Xaml.2.8" = $false
    "Microsoft.VCLibs.140.00" = $false
    "Microsoft.VCLibs.140.00.UWPDesktop" = $false
    "Clipchamp.Clipchamp" = $true
    "Microsoft.ApplicationCompatibilityEnhancements" = $false
    "Microsoft.AV1VideoExtension" = $false
    "Microsoft.AVCEncoderVideoExtension" = $false
    "Microsoft.BingNews" = $true
    "Microsoft.BingSearch" = $true
    "Microsoft.BingWeather" = $true
    "Microsoft.DesktopAppInstaller" = $false
    "Microsoft.GamingApp" = $true
    "Microsoft.GetHelp" = $false
    "Microsoft.HEIFImageExtension" = $false
    "Microsoft.HEVCVideoExtension" = $false
    "Microsoft.MicrosoftOfficeHub" = $true
    "Microsoft.MicrosoftSolitaireCollection" = $True
    "Microsoft.MicrosoftStickyNotes" = $false
    "Microsoft.MPEG2VideoExtension" = $false
    "Microsoft.PowerAutomateDesktop" = $false
    "Microsoft.RawImageExtension" = $false
    "Microsoft.SecHealthUI" = $false
    "Microsoft.StorePurchaseApp" = $false
    "Microsoft.Todos" = $false
    "Microsoft.VP9VideoExtensions" = $false
    "Microsoft.WebMediaExtensions" = $false
    "Microsoft.WebpImageExtension" = $false
    "Microsoft.Windows.DevHome" = $false
    "Microsoft.WindowsAlarms" = $false
    "Microsoft.WindowsCalculator" = $false
    "Microsoft.WindowsCamera" = $false
    "Microsoft.WindowsFeedbackHub" = $false
    "Microsoft.WindowsSoundRecorder" = $false
    "Microsoft.WindowsTerminal" = $false
    "Microsoft.Xbox.TCUI" = $true
    "Microsoft.XboxGamingOverlay" = $True
    "Microsoft.XboxIdentityProvider" = $true
    "Microsoft.XboxSpeechToTextOverlay" = $true
    "Microsoft.YourPhone" = $true
    "Microsoft.ZuneMusic" = $true
    "MicrosoftCorporationII.QuickAssist" = $false
    "MicrosoftWindows.CrossDevice" = $false
    "Microsoft.WindowsAppRuntime.2" = $false
    "MSTeams" = $true
    "Microsoft.MicrosoftEdge.Stable" = $false
    "Microsoft.WindowsStore" = $false
    "Microsoft.WidgetsPlatformRuntime" = $false
    "Microsoft.StartExperiencesApp" = $false
    "Microsoft.OutlookForWindows" = $true
    "Microsoft.Windows.Photos" = $false
    "Microsoft.WindowsNotepad" = $false
    "Microsoft.ScreenSketch" = $false
    "Microsoft.Paint" = $false
    "MicrosoftWindows.Client.WebExperience" = $false
    "Microsoft.Ink.Handwriting.en-US.1.0" = $false
    "Microsoft.Ink.Handwriting.Main.en-US.1.0.1" = $false
}

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -ne "Desktop" -or -not [Environment]::Is64BitProcess) {
    throw "Run this script in elevated, 64-bit Windows PowerShell 5.1, not PowerShell 7 or a 32-bit host."
}
foreach ($Command in @("Get-AppxPackage", "Get-AppxProvisionedPackage", "Remove-AppxPackage", "Remove-AppxProvisionedPackage")) {
    Get-Command -Name $Command -ErrorAction Stop | Out-Null
}

function Get-AppxInventory {
    $Installed = @(Get-AppxPackage -AllUsers -PackageTypeFilter All -ErrorAction Stop)
    $Provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop)
    $DependencyNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($Package in $Installed) {
        foreach ($Dependency in $Package.Dependencies) {
            # Bundle/resource relationships within one app are removed together.
            if (-not [string]::IsNullOrWhiteSpace($Dependency.Name) -and $Dependency.Name -ne $Package.Name) {
                $null = $DependencyNames.Add($Dependency.Name)
            }
        }
    }

    [pscustomobject]@{
        Installed = $Installed
        Provisioned = $Provisioned
        DependencyNames = $DependencyNames
    }
}

function Get-AppxProtectionReason {
    param([string]$Name, [object]$Inventory)

    $Packages = @($Inventory.Installed | Where-Object { $_.Name -eq $Name })
    $Reasons = [System.Collections.Generic.List[string]]::new()
    if (@($Packages | Where-Object { $_.NonRemovable }).Count) {
        $Reasons.Add("Windows marks this package as non-removable")
    }
    if (@($Packages | Where-Object { $_.IsFramework }).Count) {
        $Reasons.Add("Framework package")
    }
    if ($Packages.Count -gt 0 -and @($Packages | Where-Object { -not $_.IsResourcePackage }).Count -eq 0) {
        $Reasons.Add("Resource-only package; remove its parent app instead")
    }
    $SystemAppsPath = Join-Path $env:SystemRoot "SystemApps\"
    if (@($Packages | Where-Object {
        $_.InstallLocation -and $_.InstallLocation.StartsWith($SystemAppsPath, [System.StringComparison]::OrdinalIgnoreCase)
    }).Count) {
        $Reasons.Add("Windows SystemApps component")
    }
    if ($Inventory.DependencyNames.Contains($Name)) {
        $Reasons.Add("Dependency of an installed package")
    }

    $ProtectedNames = @(
        "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.DesktopAppInstaller",
        "Microsoft.SecHealthUI", "Microsoft.Windows.SecHealthUI", "Microsoft.AAD.BrokerPlugin",
        "Microsoft.AccountsControl", "Microsoft.CredDialogHost", "Microsoft.LockApp",
        "Microsoft.Windows.CloudExperienceHost", "Microsoft.Windows.ShellExperienceHost",
        "Microsoft.Windows.StartMenuExperienceHost", "Microsoft.Windows.Search",
        "MicrosoftWindows.Client.CBS", "MicrosoftWindows.Client.Core", "MicrosoftWindows.Client.OOBE",
        "windows.immersivecontrolpanel", "Microsoft.MicrosoftEdge*", "Microsoft.Win32WebViewHost",
        "Microsoft.VCLibs.*", "Microsoft.NET.Native.*", "Microsoft.UI.Xaml.*",
        "Microsoft.WindowsAppRuntime.*"
    )
    foreach ($Pattern in $ProtectedNames) {
        if ($Name -like $Pattern) {
            $Reasons.Add("Protected Windows, Store, installer, security, or runtime component")
            break
        }
    }
    $Reasons -join "; "
}

function Write-AppxLog {
    param([string]$Message)

    $Line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Add-Content -LiteralPath $LogPath -Value $Line -Confirm:$false
    Write-Host $Message
}

$SelectedNames = @(
    foreach ($Entry in $AppsToRemove.GetEnumerator()) {
        if ($Entry.Key -isnot [string] -or $Entry.Key -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$' -or $Entry.Value -isnot [bool]) {
            throw "Invalid AppsToRemove entry: use an exact Appx identity without wildcards and a Boolean `$true or `$false value."
        }
        if ($Entry.Value) {
            $Entry.Key
        }
    }
)
if ($ListApps) {
    $Inventory = Get-AppxInventory
    $Names = @(@($AppsToRemove.Keys) + @($Inventory.Installed.Name) + @($Inventory.Provisioned.DisplayName) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    foreach ($Name in $Names) {
        $InSourceList = $AppsToRemove.Contains($Name)
        $Reason = Get-AppxProtectionReason -Name $Name -Inventory $Inventory
        [pscustomobject]@{
            Name = $Name
            InSourceList = $InSourceList
            Remove = if ($InSourceList) { $AppsToRemove[$Name] } else { $false }
            InstalledForExistingUsers = @($Inventory.Installed | Where-Object { $_.Name -eq $Name }).Count -gt 0
            ProvisionedForNewUsers = @($Inventory.Provisioned | Where-Object { $_.DisplayName -eq $Name }).Count -gt 0
            Protected = -not [string]::IsNullOrWhiteSpace($Reason)
            ProtectionReason = $Reason
        }
    }
    return
}
if ($SelectedNames.Count -eq 0) {
    Write-Warning "No apps are enabled in AppsToRemove. Change the desired entries from `$false to `$true. No changes were made."
    return
}

$Inventory = Get-AppxInventory
$Blocked = @(
    foreach ($Name in $SelectedNames) {
        $Reason = Get-AppxProtectionReason -Name $Name -Inventory $Inventory
        if (-not [string]::IsNullOrWhiteSpace($Reason)) {
            "${Name}: $Reason"
        }
    }
)
if ($Blocked.Count) {
    $BlockedMessage = $Blocked -join [Environment]::NewLine
    throw "Protected apps were selected. Set their AppsToRemove entries back to `$false. No apps were removed.`n$BlockedMessage"
}

$Results = @(
    foreach ($Name in $SelectedNames) {
        [pscustomobject]@{
            Name = $Name
            Status = "NotRequested"
            RegisteredPackagesRemoved = 0
            ProvisionedPackagesRemoved = 0
            RestartNeeded = $false
            ErrorMessage = $null
        }
    }
)
Write-Host "Selected apps: $($SelectedNames -join ', ')"
if (-not $PSCmdlet.ShouldProcess("$env:COMPUTERNAME / all existing and future users", "Remove $($SelectedNames.Count) selected Appx identities and their provisioning")) {
    $Results
    return
}

$LogDirectory = Split-Path -Parent ([System.IO.Path]::GetFullPath($LogPath))
New-Item -Path $LogDirectory -ItemType Directory -Force -Confirm:$false | Out-Null
Write-AppxLog "Starting selected Appx removal for all existing and future users. Source: inline AppsToRemove list."
$FailedCount = 0
foreach ($Result in $Results) {
    $Name = $Result.Name
    $Issues = [System.Collections.Generic.List[string]]::new()
    $WasPresent = @($Inventory.Installed | Where-Object { $_.Name -eq $Name }).Count -gt 0 -or
        @($Inventory.Provisioned | Where-Object { $_.DisplayName -eq $Name }).Count -gt 0
    try {
        foreach ($Package in @($Inventory.Provisioned | Where-Object { $_.DisplayName -eq $Name })) {
            try {
                $Removal = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $Package.PackageName -ErrorAction Stop
                $Result.ProvisionedPackagesRemoved++
                if ($Removal.RestartNeeded) {
                    $Result.RestartNeeded = $true
                }
                Write-AppxLog "Deprovisioned $($Package.PackageName)."
            }
            catch {
                $Issues.Add("Deprovisioning $($Package.PackageName) failed: $($_.Exception.Message)")
                Write-AppxLog "ERROR: $($Issues[$Issues.Count - 1])"
            }
        }

        # Remove bundles before their contained main packages.
        $Packages = @(Get-AppxPackage -AllUsers -Name $Name -PackageTypeFilter Main, Bundle, Optional -ErrorAction Stop |
            Sort-Object @{ Expression = { [int]$_.IsBundle }; Descending = $true }, PackageFullName)
        foreach ($Package in $Packages) {
            $StillPresent = @(Get-AppxPackage -AllUsers -Name $Name -PackageTypeFilter All -ErrorAction Stop |
                Where-Object { $_.PackageFullName -eq $Package.PackageFullName })
            if ($StillPresent.Count -eq 0) {
                Write-AppxLog "$($Package.PackageFullName) was already removed with its parent package."
                continue
            }
            try {
                Remove-AppxPackage -AllUsers -Package $Package.PackageFullName -Confirm:$false -ErrorAction Stop
                $Result.RegisteredPackagesRemoved++
                Write-AppxLog "Removed $($Package.PackageFullName) for all users."
            }
            catch {
                $Issues.Add("Removing $($Package.PackageFullName) failed: $($_.Exception.Message)")
                Write-AppxLog "ERROR: $($Issues[$Issues.Count - 1])"
            }
        }

        $RemainingInstalled = @(Get-AppxPackage -AllUsers -Name $Name -PackageTypeFilter All -ErrorAction Stop)
        $RemainingProvisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop |
            Where-Object { $_.DisplayName -eq $Name })
        if ($RemainingInstalled.Count -gt 0 -or $RemainingProvisioned.Count -gt 0) {
            $Issues.Add("Verification found $($RemainingInstalled.Count) registered/staged and $($RemainingProvisioned.Count) provisioned package(s) still present.")
        }
    }
    catch {
        $Issues.Add("Processing or inventory verification failed: $($_.Exception.Message)")
        Write-AppxLog "ERROR: $($Issues[$Issues.Count - 1])"
    }

    if ($Issues.Count) {
        $Result.Status = "Failed"
        $Result.ErrorMessage = $Issues -join " "
        $FailedCount++
        Write-AppxLog "ERROR: $Name removal did not complete successfully. $($Result.ErrorMessage)"
    }
    else {
        $Result.Status = if ($WasPresent) { "Removed" } else { "AlreadyAbsent" }
        Write-AppxLog "$Name status: $($Result.Status). Restart needed: $($Result.RestartNeeded)."
    }
    $Result
}
Write-AppxLog "Appx removal finished. Selected: $($Results.Count). Failed: $FailedCount."
if ($FailedCount) {
    throw "$FailedCount app removal(s) failed. Review $LogPath and the per-app results. No automatic reboot or rollback was performed."
}
