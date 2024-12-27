use log.nu

const category = "nu-install pacman"

# Installs packages using pacman.
export def main [
  packages: list<string> # Packages to install
] {
  if (which pacman | is-empty) {
    log warning -c $category "pacman not found"
    return
  }

  let installed_packages = ^pacman -Qq | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info -c $category $"Installing: ($missing_packages)"
    ^sudo pacman -Syyu --noconfirm ...$missing_packages
  }
}
