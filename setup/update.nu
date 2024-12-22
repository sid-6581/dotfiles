use ../config/.config/nushell/scripts/log.nu

const category = "update"

# Runs an update closure if an application exists.
export def main [
  application: string
  command: closure
] {
  if (which $application | is-empty) {
    log warning -c $category $"($application) not found"
  } else {
    log info -c $category $"Updating ($application)"
    do $command
  }
}
