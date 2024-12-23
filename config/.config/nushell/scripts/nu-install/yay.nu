use log.nu

const category = "nu-install yay"

# Installs packages using yay.
export def "nu-install yay" [
  packages: list<string> # Packages to install
] {
  if (which pacman | is-empty) {
    log error -c $category "yay not found"
    return
  }

  let installed_packages = ^yay -Qq | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info -c $category $"Installing: ($missing_packages)"
    ^yay -Syyu --noconfirm ...$missing_packages
  }
}
