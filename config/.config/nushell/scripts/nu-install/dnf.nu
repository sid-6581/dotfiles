use log.nu

# Installs packages using dnf.
export def "nu-install dnf" [
  packages: list<string> # Packages to install
] {
  let installed_packages = ^rpm -qa --queryformat "%{NAME}\n" | lines
  let missing_packages = $packages | filter { $in not-in $installed_packages }

  if ($missing_packages | is-not-empty) {
    log info $"Installing dnf packages: ($missing_packages)"
    ^sudo dnf install -qy ...$missing_packages
  }
}
