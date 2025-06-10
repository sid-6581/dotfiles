use log.nu

# Installs binaries using cargo.
export def main [
  binaries: list<string> # Binaries to install
] {
  $env.LOG_CATEGORY = "nu-install cargo"

  if (which cargo | is-empty) {
    log warning "cargo not found"
    return
  }

  let installed_binaries = (
    ^cargo install --list
    | lines
    | where { $in !~ "^ " }
    | split column " " -c
    | rename name
    | get name
  )
  let missing_binaries = $binaries | where { $in not-in $installed_binaries }

  if ($missing_binaries | is-not-empty) {
    log info $"Installing: ($missing_binaries)"
    ^cargo install ...$missing_binaries
  }
}
