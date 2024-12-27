use std
use log.nu

const category = "nu-install winget"

# Installs apps using winget (Windows only).
export def main [
  apps: list<string>      # Apps to install (exact ID)
] {
  if (which winget | is-empty) {
    log warning -c $category "winget not found"
    return
  }

  for $app in $apps {
    try {
      ^winget list --accept-source-agreements --exact --id $app o+e> (std null-device)
    } catch {
      log info -c $category $"Installing: ($app)"
      ^winget install --accept-source-agreements --silent --exact --id $app
    }
  }
}

# Uninstalls apps using winget (Windows only).
export def uninstall [
  apps: list<string>      # Apps to uninstall (exact name)
] {
  if (which winget | is-empty) {
    log warning -c $category "winget not found"
    return
  }

  for $app in $apps {
    try {
      ^winget list --accept-source-agreements --exact --name $app o+e> (std null-device)
      log info -c $category $"Uninstalling: ($app)"
      ^winget uninstall --accept-source-agreements --silent --exact --name $app
    } catch {
    }
  }
}
