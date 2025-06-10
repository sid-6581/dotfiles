use log.nu

# Installs buckets and apps using scoop (Windows only). Will install scoop if it's not already installed.
export def main [
  --buckets (-b): list<string>   # Buckets to install
  --apps (-a): list<string>      # Apps to install
  --sudo-apps (-s): list<string> # Apps to install with sudo
] {
  $env.LOG_CATEGORY = "nu-install scoop"

  install-scoop

  if (which scoop | is-empty) {
    log warning "scoop not found"
    return
  }

  let installed = ^scoop export | from json

  let missing_buckets = $buckets | default [] | where { $in not-in $installed.buckets.Name }

  if ($missing_buckets | is-not-empty) {
    log info $"Adding buckets: ($missing_buckets)"
    $missing_buckets | each { ^scoop bucket add $in }
  }

  let missing_apps = $apps | default [] | where { $in not-in $installed.apps.Name }

  if ($missing_apps | is-not-empty) {
    log info $"Adding apps: ($missing_apps)"
    $missing_apps | each { ^scoop install -s $in }
  }

  let missing_sudo_apps = $sudo_apps | default [] | where { $in not-in $installed.apps.Name }

  if ($missing_sudo_apps | is-not-empty) {
    if (which sudo | is-empty) {
      ^scoop install sudo
    }

    log info $"Adding sudo apps: ($missing_sudo_apps)"
    $missing_sudo_apps | each { ^sudo.cmd $"($env.HOME)/scoop/shims/scoop.cmd" install -g -s $in }
  }
}

# Uninstalls buckets and apps using scoop (Windows only). Will install scoop if it's not already installed.
export def uninstall [
  --buckets (-b): list<string>   # Buckets to uninstall
  --apps (-a): list<string>      # Apps to uninstall
  --sudo-apps (-s): list<string> # Apps to uninstall with sudo
] {
  $env.LOG_CATEGORY = "nu-install scoop uninstall"

  install-scoop

  if (which scoop | is-empty) {
    log warning "scoop not found"
    return
  }

  let installed = ^scoop export | from json

  let found_buckets = (
    $buckets
    | default []
    | where { $in in $installed.buckets.Name }
  )

  if ($found_buckets | is-not-empty) {
    log info $"Removing buckets: ($found_buckets)"
    $found_buckets | each { ^scoop bucket rm $in }
  }

  let found_apps = (
    $apps
    | default []
    | where { $in in ($installed.apps | where Info == "").Name }
  )

  if ($found_apps | is-not-empty) {
    log info $"Uninstalling apps: ($found_apps)"
    $found_apps | each { ^scoop uninstall $in }
  }

  let found_sudo_apps = (
    $sudo_apps
    | default []
    | where { $in in ($installed.apps | where Info == "Global install").Name }
  )

  if ($found_sudo_apps | is-not-empty) {
    if (which sudo | is-empty) {
      ^scoop install sudo
    }

    $found_sudo_apps | each { ^sudo.cmd $"($env.HOME)/scoop/shims/scoop.cmd" uninstall -g $in }
    log info $"Uninstalling sudo apps: ($found_sudo_apps)"
  }
}

def install-scoop [] {
  $env.LOG_CATEGORY = "nu-install scoop"

  if $nu.os-info.name != "windows" {
    log error $"scoop is only supported on Windows"
    exit
  }

  if (which scoop | is-empty) {
    log info "Installing scoop"
    ^powershell -NoProfile -NonInteractive -ExecutionPolicy ByPass -Command "Invoke-WebRequest -UseBasicParsing get.scoop.sh | Invoke-Expression"
    ^scoop install -s git
    ^scoop config update_nightly true
    try { ^git config --system --unset credential.helper }
  }
}
