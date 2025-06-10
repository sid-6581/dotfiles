use log.nu

# Installs packages using pacman.
export def main [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install pacman"

  if (which pacman | is-empty) {
    log warning "pacman not found"
    return
  }

  let installed_packages = ^pacman -Qq | lines
  let missing_packages = $packages | where { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"Installing: ($missing_packages)"
    ^sudo pacman -Syu --noconfirm ...$missing_packages
  }
}

# Uninstalls packages using pacman.
export def uninstall [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install pacman uninstall"

  if (which pacman | is-empty) {
    log warning "pacman not found"
    return
  }

  let installed_packages = ^pacman -Qq | lines
  let found_packages = $packages | where { $in in $installed_packages }

  if ($found_packages | is-not-empty) {
    log info $"Uninstalling: ($found_packages)"
    ^sudo pacman -Rsu --noconfirm ...$found_packages
  }
}
