#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

use config/.config/nushell/scripts/globals.nu
use config/.config/nushell/scripts/log.nu

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

if (which scoop | is-empty) {
  log warning "scoop not installed, skipping update"
} else {
  log info "Updating scoop (sudo)"
  ^scoop update -g -s '*'
}

exit
