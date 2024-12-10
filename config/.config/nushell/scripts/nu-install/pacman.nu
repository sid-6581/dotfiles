use log.nu

# Installs packages using pacman.
export def "nu-install pacman" [
  packages: list<string> # Packages to install
] {
  if (which pacman | is-empty) {
    log warning "pacman not found, skipping nu-install pacman"
    return
  }

  let installed_packages = ^pacman -Qq | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"Installing pacman packages: ($missing_packages)"
    ^sudo pacman -Syu --noconfirm ...$missing_packages
  }
}
