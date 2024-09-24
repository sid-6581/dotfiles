use std
use log.nu

# Installs apps using winget (Windows only).
export def "nu-install winget" [
  apps: list<string>      # Apps to install (exact ID)
] {
  if (which winget | is-empty) {
    log warning "winget not found, skipping nu-install winget"
    return
  }

  for $app in $apps {
    try {
      ^winget list --exact --id $app o> (std null-device)
    } catch {
      log info $"Installing winget app: ($app)"
      ^winget install --silent --exact --id $app
    }
  }
}
