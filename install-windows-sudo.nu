#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

source config/.config/nushell/scripts/globals.nu

use config/.config/nushell/scripts/nu-install *
use config/.config/nushell/scripts/nu-install/log.nu

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

if (which pwsh | is-empty) {
  log warning "pwsh not installed, skipping sudo PowerShell script"
} else {
  pwsh -NoProfile -NonInteractive -ExecutionPolicy ByPass -File $"($env.FILE_PWD)/install-windows-sudo.ps1"
}

nu-install scoop --sudo-apps [
  JetBrains-Mono
  JetBrainsMono-NF
  JetBrainsMono-NF-Mono
]

exit
