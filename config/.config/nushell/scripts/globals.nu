# This file should contain things that are required everywhere.
# It should be sourced from env.nu, but also from scripts that require certain the standard environment variables and paths.

$env.HOME = if $nu.os-info.name == "linux" { $env.HOME } else { $env.HOME? | default $env.USERPROFILE }
$env.XDG_CACHE_HOME = $env.HOME | path join .cache
$env.XDG_CONFIG_HOME = $env.HOME | path join .config
$env.XDG_DATA_HOME = $env.HOME | path join .local share
$env.XDG_STATE_HOME = $env.HOME | path join .local state
$env.PNPM_HOME = $env.HOME | path join .local share pnpm

# Running in block to prevent variable leakage.
if true {
  # Handle being sourced from env.nu/config.nu where the path isn't separated yet,
  # as well as scripts where the path is already separated.
  let is_list = $env.PATH | describe | str starts-with list

  let paths = if $is_list {
    $env.PATH
  } else {
    $env.PATH | split row (char esep)
  }

  let paths = [
    ($env.HOME | path join .local bin)
    ($env.HOME | path join .cargo bin)
    ($env.HOME | path join .local share bob nvim-bin)
    (if $nu.os-info.name != "linux" { $env.HOME | path join scoop shims } else { null })
    ($env.HOME | path join .local share pnpm)
    ($env.HOME | path join go bin)
    ...$paths
  ]
  | compact -e
  | filter {|p| $p !~ "(?i)^/mnt/./" }
  | path expand --no-symlink
  | uniq

  $env.PATH = if $is_list {
    $paths
  } else {
    $paths | str join (char esep)
  }
}
