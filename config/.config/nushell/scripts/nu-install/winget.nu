use std
use log.nu

# Installs apps using winget (Windows only).
export def "nu-install winget" [
  apps: list<string>      # Apps to install (exact ID)
] {
  if (which winget | is-empty) {
    log warning "nu-install winget: winget not found"
    return
  }

  for $app in $apps {
    try {
      ^winget list --accept-source-agreements --exact --id $app o+e> (std null-device)
    } catch {
      log info $"nu-install winget: Installing: ($app)"
      ^winget install --accept-source-agreements --silent --exact --id $app
    }
  }
}

# Uninstalls apps using winget (Windows only).
export def "nu-install winget uninstall" [
  apps: list<string>      # Apps to uninstall (exact name)
] {
  if (which winget | is-empty) {
    log warning "nu-install winget: winget not found"
    return
  }

  for $app in $apps {
    try {
      ^winget list --accept-source-agreements --exact --name $app o+e> (std null-device)
      log info $"nu-install winget: Uninstalling: ($app)"
      ^winget uninstall --accept-source-agreements --silent --exact --name $app
    } catch {
    }
  }
}
