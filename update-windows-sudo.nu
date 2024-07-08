#!/usr/bin/env nu

# This script must be started from Windows as an admin.
if $nu.os-info.name != "windows" or not (is-admin) {
  log error $"($env.CURRENT_FILE) must be run on Windows as an administrator"
  exit
}

# Run everything from the Windows home directory, since some tools don't like being run from the WSL UNC path.
cd $env.HOME

let scoop_filter = {|it| $it !~ "pdat|Latest|shiny"}

scoop update -q -g -s '*' | filter $scoop_filter

exit
