#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

source config/.config/nushell/scripts/globals.nu

use config/.config/nushell/scripts/nu-install *
use config/.config/nushell/scripts/log.nu

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

# Enable developer mode
^reg add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' /f /v 'AllowDevelopmentWithoutDevLicense' /t REG_DWORD /d 0x1 | null

# Keyboard repeat rate
let keyboardResponsePath = 'HKCU\Control Panel\Accessibility\Keyboard Response'
^reg add $keyboardResponsePath /f /v 'BounceTime' /t REG_DWORD /d 0x0 | null
^reg add $keyboardResponsePath /f /v 'AutoRepeatDelay' /t REG_DWORD /d 0x108 | null
^reg add $keyboardResponsePath /f /v 'AutoRepeatRate' /t REG_DWORD /d 0xA | null
^reg add $keyboardResponsePath /f /v 'DelayBeforeAcceptance' /t REG_DWORD /d 0x0 | null
^reg add $keyboardResponsePath /f /v 'Flags' /t REG_DWORD /d 0x1B | null

# Disable StickyKeys
^reg add 'HKCU\Control Panel\Accessibility\StickyKeys' /f /v 'Flags' /t REG_DWORD /d 0x1A | null

# Underline access keys even when not holding Alt
^reg add 'HKCU\Control Panel\Accessibility\Keyboard Preference' /f /v 'On' /t REG_DWORD /d 0x1 | null

exit
