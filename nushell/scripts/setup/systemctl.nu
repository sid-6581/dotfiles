# Enables and starts a systemctl service.
export def enable [
  ...services: string   # Service names
  --user(-u)            # True if service is a user service
] {
  use ../log.nu
  $env.LOG_CATEGORY = "setup systemctl enable"

  def --wrapped sc [...args] {
    if $user {
      ^systemctl --user ...$args
    } else {
      ^sudo systemctl ...$args
    }
  }

  for $service in $services {
    let details = sc show $service
    | lines
    | parse "{key}={value}"
    | transpose -r -d

    if $details.LoadState? == "not-found" {
      log warning $"Service ($service) not found"
      continue
    }

    if $details.UnitFileState? != "enabled" or $details.ActiveState? != "active" {
      log info $"Starting ($service)"
      try {
        sc enable --now $service
      }
    }
  }
}
