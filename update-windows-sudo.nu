#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

source config/.config/nushell/scripts/globals.nu

use config/.config/nushell/scripts/log.nu

let log_file = log update-file

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

do {
  if (which scoop | is-empty) {
    log warning "scoop not installed, skipping update" --file $log_file
  } else {
    log info "Updating scoop (sudo)" --file $log_file
    ^scoop update -g -s '*'
  }
} o+e>> $log_file

exit
