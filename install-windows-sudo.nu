#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

source config/.config/nushell/scripts/globals.nu

use config/.config/nushell/scripts/nu-install *
use config/.config/nushell/scripts/log.nu
use config/.config/nushell/scripts/windows.nu

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

# Enable developer mode
windows registry add 'HKLM\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowDevelopmentWithoutDevLicense' 0x1

# Keyboard repeat rate
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'BounceTime' '0'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'AutoRepeatDelay' '264'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'AutoRepeatRate' '16'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'DelayBeforeAcceptance' '0'
windows registry add 'HKCU\Control Panel\Accessibility\Keyboard Response' 'Flags' '27'

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

# Disable Windows Defender
# windows registry add 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' 'DisableRealtimeMonitoring' 0x1
windows registry add 'HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks' 'Enabled' 0x0
windows registry add 'HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'Enabled' 0x0
windows registry add 'HKLM\Software\Policies\Microsoft\Windows Defender\Spynet' 'SpynetReporting' 0x0
windows registry add 'HKLM\Software\Policies\Microsoft\Windows Defender\Spynet' 'SubmitSamplesConsent' 0x0

# Stop search indexing
^sc stop 'wsearch' | null
^sc config 'wsearch' start=disabled | null

exit
