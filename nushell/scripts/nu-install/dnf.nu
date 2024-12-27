use log.nu

# Installs packages using dnf.
export def main [
  packages: list<string> # Packages to install
] {
  $env.LOG_CATEGORY = "nu-install dnf"

  if (which dnf | is-empty) {
    log warning "dnf not found"
    return
  }

  let installed_packages = ^rpm -qa --queryformat "%{NAME}\n" | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"Installing: ($missing_packages)"
    ^sudo dnf install -qy ...$missing_packages
  }
}
