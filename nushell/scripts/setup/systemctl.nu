# Enables and starts a systemctl service.
export def enable [
  ...services: string   # Service names
  --user(-u)            # True if service is a user service
] {
  use ../log.nu
  $env.LOG_CATEGORY = "setup systemctl enable"

  for $service in $services {
    let details = ^systemctl show $service
    | lines
    | parse "{key}={value}"
    | transpose -r -d

    if $details.LoadState? == "not-found" {
      log warning $"Service ($service) not found"
      continue
    }

    if $details.UnitFileState? != "enabled" or $details.ActiveState? != "active" {
      log info $"Starting ($service)"

      let command = [
        ...(if $user { [] } else { ["sudo"] })
        "systemctl"
        ...(if $user { ["--user"] } else { [] })
        "enable"
        "--now"
        $service
      ]

      try { run-external $command }
    }
  }
}
