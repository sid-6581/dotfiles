# This file should contain things that are required everywhere.
# It should be sourced from env.nu, but also from scripts that require certain the standard environment variables and paths.
export-env {
  $env.HOME = if $nu.os-info.name == "linux" { $env.HOME } else { $env.HOME? | default $env.USERPROFILE }
  $env.XDG_CACHE_HOME = $env.HOME | path join .cache
  $env.XDG_CONFIG_HOME = $env.HOME | path join .config
  $env.XDG_DATA_HOME = $env.HOME | path join .local share
  $env.XDG_STATE_HOME = $env.HOME | path join .local state
  $env.PNPM_HOME = $env.HOME | path join .local share pnpm

  $env.PATH = (
    [
      ($env.HOME | path join .local bin)
      ($env.HOME | path join .cargo bin)
      ($env.HOME | path join .local share bob nvim-bin)
      (if $nu.os-info.name == "windows" { $env.HOME | path join scoop shims } else { null })
      ($env.HOME | path join .local share pnpm)
      ($env.HOME | path join go bin)
      ($env.HOME | path join .dotnet)
      ($env.HOME | path join .dotnet tools)
      ...$env.PATH
    ]
    | compact -e
    | filter {|p| $p !~ "(?i)^/mnt/./" }
    | path expand --no-symlink
    | uniq
  )
}
