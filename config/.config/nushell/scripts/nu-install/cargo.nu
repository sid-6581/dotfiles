use log.nu

# Installs binaries using cargo.
export def "nu-install cargo" [
  binaries: list<string> # Binaries to install
] {
  if (which cargo | is-empty) {
    log error "cargo not found, skipping nu-install cargo"
    return
  }

  let installed_binaries = (
    ^cargo install --list
    | lines
    | filter { $in !~ "^ " }
    | split column " " -c
    | rename name
    | get name
  )
  let missing_binaries = $binaries | filter { $in not-in $installed_binaries }

  if ($missing_binaries | is-not-empty) {
    log info $"Installing cargo binaries: ($missing_binaries)"
    ^cargo install ...$missing_binaries
  }
}
