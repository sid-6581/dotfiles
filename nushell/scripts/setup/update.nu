# Runs an update closure if an application exists.
export def app [
  application: string
  command: closure
] {
  use ../log.nu
  $env.LOG_CATEGORY = "setup update app"

  if (which $application | is-empty) {
    log warning $"($application) not found"
  } else {
    log info $"Updating ($application)"
    try { do $command }
  }
}
