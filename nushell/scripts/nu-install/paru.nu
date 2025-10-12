use log.nu

# Installs packages using paru.
export def main [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install paru"

  if (which paru | is-empty) {
    log warning "paru not found"
    return
  }

  let installed_packages = ^paru -Qq | lines
  let missing_packages = $packages | where { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"Installing: ($missing_packages)"
    ^paru -Syu --noconfirm --disable-download-timeout --skipreview ...$missing_packages
  }
}

# Uninstalls packages using paru.
export def uninstall [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install paru uninstall"

  if (which paru | is-empty) {
    log warning "paru not found"
    return
  }

  let installed_packages = ^paru -Qq | lines
  let found_packages = $packages | where { $in in $installed_packages }

  if ($found_packages | is-not-empty) {
    log info $"Uninstalling: ($found_packages)"
    ^paru -Rsu --noconfirm ...$found_packages
  }
}
