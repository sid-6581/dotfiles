#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

use config/.config/nushell/scripts/globals.nu
use config/.config/nushell/scripts/nu-install *
use config/.config/nushell/scripts/log.nu
use config/.config/nushell/scripts/windows.nu

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

nu-install winget uninstall [
  "Copilot"
  "Cross Device Experience Host"
  "Dev Home (Preview)"
  "Feedback Hub"
  "Get Help"
  "IIS 10.0 Express"
  "MSN Weather"
  "Microsoft .NET Framework 4.8.1 Targeting Pack"
  "Microsoft Bing Search"
  "Microsoft Family"
  "Microsoft ODBC Driver 17 for SQL Server"
  "Microsoft SQL Server 2019 LocalDB"
  "Microsoft System CLR Types for SQL Server 2019"
  "Microsoft Tips"
  "Microsoft Web Deploy 4.0"
  "Phone Link"
  "Web Search from Microsoft Bing"
  "Windows Camera"
]

# Enable developer mode
windows registry add 'HKLM\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowDevelopmentWithoutDevLicense' 0x1

# Keyboard repeat rate
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'BounceTime' '0'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'AutoRepeatDelay' '264'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'AutoRepeatRate' '16'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'DelayBeforeAcceptance' '0'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'Flags' '26'

# Disable StickyKeys
windows registry add 'HKCU\Control Panel\Accessibility\StickyKeys' 'Flags' '26'

# Underline access keys even when not holding Alt
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Preference' 'On' '1'

# Disable start menu search options
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsMSACloudSearchEnabled' 0x0
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsAADCloudSearchEnabled' 0x0
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsDeviceSearchHistoryEnabled' 0x0
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsDynamicSearchBoxEnabled' 0x0
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0x0
windows registry add 'HKCU\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 0x1

# Disable recommended section
windows registry add 'HKCU\Software\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 0x1
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0x0
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_SearchFiles' 0x0
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' 0x0
windows registry add 'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 0x1

# Disable showing tabs in apps when pressing Alt+Tab
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'MultiTaskingAltTabFilter' 0x3

# Disallow title bar window shake
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisallowShaking' 0x1

# Disable Windows Defender
windows registry add 'HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection' 'DisableRealtimeMonitoring' 0x1
windows registry add 'HKLM\Software\CurrentControlSet\Control\CI\Policy' 'VerifiedAndReputablePolicyState' 0x0
windows registry add 'HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks' 'Enabled' 0x0
windows registry add 'HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'Enabled' 0x0
windows registry add 'HKLM\Software\Policies\Microsoft\Windows Defender\Spynet' 'SpynetReporting' 0x0
windows registry add 'HKLM\Software\Policies\Microsoft\Windows Defender\Spynet' 'SubmitSamplesConsent' 0x0

# Disable malicious software removal tool
windows registry add 'HKLM\SOFTWARE\Policies\Microsoft\MRT' 'DontOfferThroughWUAU' 0x1

# Disable using sign-in info to automatically finish setting up
windows registry add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System' 'DisableAutomaticRestartSignOn' 0x1

# Disable finish setting up PC
windows registry add 'HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' 'ScoobeSystemSettingEnabled' 0x0

# Stop search indexing
^sc stop 'wsearch' | null
^sc config 'wsearch' start=disabled | null

rm -rf ($env.HOME | path join .templateengine)
rm -rf ($env.HOME | path join Contacts)
rm -rf ($env.HOME | path join Documents Downloads)
rm -rf ($env.HOME | path join Documents IISExpress)
rm -rf ($env.HOME | path join Documents "My Web Sites")
rm -rf ($env.HOME | path join Favorites)
rm -rf ($env.HOME | path join Links)
rm -rf ($env.HOME | path join Music)
rm -rf ($env.HOME | path join Searches)
