use log.nu

# Installs packages using yay.
export def main [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install yay"

  if (which yay | is-empty) {
    log warning "yay not found"
    return
  }

  let installed_packages = ^yay -Qq | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"Installing: ($missing_packages)"
    ^yay -Syyu --noconfirm ...$missing_packages
  }
}

# Uninstalls packages using yay.
export def uninstall [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install yay uninstall"

  if (which yay | is-empty) {
    log warning "yay not found"
    return
  }

  let installed_packages = ^yay -Qq | lines
  let found_packages = $packages | filter { $in in $installed_packages }

  if ($found_packages | is-not-empty) {
    log info $"Uninstalling: ($found_packages)"
    ^yay -Rsu --noconfirm ...$found_packages
  }
}
