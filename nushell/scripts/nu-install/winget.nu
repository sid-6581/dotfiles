use std
use log.nu

# Installs apps using winget (Windows only).
export def main [
  apps: list<string>      # Apps to install (exact ID)
] {
  $env.LOG_CATEGORY = "nu-install winget"

  if (which winget | is-empty) {
    log warning "winget not found"
    return
  }

  for $app in $apps {
    try {
      ^winget list --accept-source-agreements --exact --id $app o+e> (std null-device)
    } catch {
      log info $"Installing: ($app)"
      ^winget install --accept-source-agreements --silent --exact --id $app
    }
  }
}

# Uninstalls apps using winget (Windows only).
export def uninstall [
  apps: list<string>      # Apps to uninstall (exact name)
] {
  $env.LOG_CATEGORY = "nu-install winget uninstall"

  if (which winget | is-empty) {
    log warning "winget not found"
    return
  }

  for $app in $apps {
    try {
      ^winget list --accept-source-agreements --exact --name $app o+e> (std null-device)
      log info $"Uninstalling: ($app)"
      ^winget uninstall --accept-source-agreements --silent --exact --name $app
    } catch {
    }
  }
}
