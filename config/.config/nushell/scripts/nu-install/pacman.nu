use log.nu

# Installs packages using pacman.
export def "nu-install pacman" [
  packages: list<string> # Packages to install
] {
  if (which pacman | is-empty) {
    log error "nu-install pacman: pacman not found"
    return
  }

  let installed_packages = ^pacman -Qq | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"nu-install pacman: Installing: ($missing_packages)"
    ^sudo pacman -Syyu --noconfirm ...$missing_packages
  }
}
