use log.nu

# Installs buckets and apps using scoop (Windows only). Will install scoop if it's not already installed.
export def "nu-install scoop" [
  --buckets (-b): list<string>   # Buckets to install
  --apps (-a): list<string>      # Apps to install
  --sudo-apps (-s): list<string> # Apps to install with sudo
] {
  # Set the CD temporarily because scoop doesn't like being called with a PWD inside WSL.
  cd $env.HOME

  install-scoop

  if (which scoop | is-empty) {
    log warning "scoop not found, skipping nu-install scoop"
    return
  }

  let installed = ^scoop export | from json

  let missing_buckets = $buckets | default [] | filter { $in not-in $installed.buckets.Name }

  if ($missing_buckets | is-not-empty) {
    log info $"Adding scoop buckets: ($missing_buckets)"
    $missing_buckets | each { ^scoop bucket add $in }
  }

  let missing_apps = $apps | default [] | filter { $in not-in $installed.apps.Name }

  if ($missing_apps | is-not-empty) {
    log info $"Adding scoop apps: ($missing_apps)"
    $missing_apps | each { ^scoop install -s $in }
  }

  let missing_sudo_apps = $sudo_apps | default [] | filter { $in not-in $installed.apps.Name }

  if ($missing_sudo_apps | is-not-empty) {
    if (which sudo | is-empty) {
      ^scoop install sudo
    }

    log info $"Adding scoop sudo apps: ($missing_sudo_apps)"
    $missing_sudo_apps | each { ^sudo.cmd $"($env.HOME)/scoop/shims/scoop.cmd" install -g -s $in }
  }
}

# Uninstalls buckets and apps using scoop (Windows only). Will install scoop if it's not already installed.
export def "nu-install scoop uninstall" [
  --buckets (-b): list<string>   # Buckets to uninstall
  --apps (-a): list<string>      # Apps to uninstall
  --sudo-apps (-s): list<string> # Apps to uninstall with sudo
] {
  # Set the CD temporarily because scoop doesn't like being called with a PWD inside WSL.
  cd $env.HOME

  install-scoop

  if (which scoop | is-empty) {
    log warning "scoop not found, skipping nu-install scoop"
    return
  }

  let installed = ^scoop export | from json

  let found_buckets = $buckets | default [] | filter { $in in $installed.buckets.Name }

  if ($found_buckets | is-not-empty) {
    log info $"Removing scoop buckets: ($found_buckets)"
    $found_buckets | each { ^scoop bucket rm $in }
  }

  let found_apps = $apps | default [] | filter { $in in $installed.apps.Name }

  if ($found_apps | is-not-empty) {
    log info $"Uninstalling scoop apps: ($found_apps)"
    $found_apps | each { ^scoop uninstall -s $in }
  }

  let found_sudo_apps = $sudo_apps | default [] | filter { $in in $installed.apps.Name }

  if ($found_sudo_apps | is-not-empty) {
    if (which sudo | is-empty) {
      ^scoop install sudo
    }

    $found_sudo_apps | each { ^sudo.cmd $"($env.HOME)/scoop/shims/scoop.cmd" uninstall -g -s $in }
    log info $"Uninstalling scoop sudo apps: ($found_sudo_apps)"
  }
}

def install-scoop [] {
  if (which scoop | is-empty) {
    log info "Installing scoop"
    ^powershell -NoProfile -NonInteractive -ExecutionPolicy ByPass -Command "Invoke-WebRequest -UseBasicParsing get.scoop.sh | Invoke-Expression"
    ^scoop install -s git
    ^scoop config update_nightly true
    do -i { ^git config --system --unset credential.helper }
  }
}
