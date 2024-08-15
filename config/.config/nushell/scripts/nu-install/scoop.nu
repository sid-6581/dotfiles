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
    log error "scoop not found, skipping nu-install scoop"
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
    $missing_sudo_apps | each { ^sudo scoop install -g -s $in }
  }
}

def install-scoop [] {
  if (which scoop | is-empty) {
    log info "Installing scoop"
    ^powershell -NoProfile -NonInteractive -ExecutionPolicy ByPass -Command "Invoke-WebRequest -UseBasicParsing get.scoop.sh | Invoke-Expression"
    ^scoop install -s git
    ^scoop config update_nightly true
  }
}
