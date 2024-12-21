# Runs an update closure if an application exists.
export def main [
  application: string
  command: closure
] {
  if (which $application | is-empty) {
    log warning -c "update" $"($application) not found"
  } else {
    log info -c "update" $"Updating ($application)"
    do $command
  }
}
