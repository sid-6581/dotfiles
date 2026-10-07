# Merges portable Codex defaults into the local configuration.
export def main [] {
  use ../log.nu
  $env.LOG_CATEGORY = "setup codex"

  const defaults_path = path self files/codex/defaults.toml
  let config_home = $env.CODEX_HOME? | default ($nu.home-dir | path join .codex) | path expand
  let config_path = $config_home | path join config.toml
  let config_exists = $config_path | path exists
  let config = if $config_exists { open $config_path } else { {} }
  let defaults = open $defaults_path
  let new_config = (
    $config
    # Legacy sandbox settings take precedence over default_permissions.
    | reject --optional sandbox_mode sandbox_workspace_write
    | merge deep --strategy overwrite $defaults
  )

  if $new_config == $config {
    log info $"($config_path) is already up to date"
    return
  }

  let new_config_text = $new_config | to toml
  mkdir $config_home
  let temp_path = mktemp --tmpdir-path $config_home config.toml.XXXXXX

  try {
    if $config_exists {
      # Preserve permissions, and back up the original bytes before replacing it.
      cp --preserve [mode] $config_path $temp_path
    }

    $new_config_text | save --raw --force $temp_path

    if $config_exists {
      log info $"Backing up ($config_path) to ($config_path).bak"
      cp --force --preserve [mode] $config_path $"($config_path).bak"
    }

    log info $"Writing ($config_path)"
    mv --force $temp_path $config_path
  } catch {|err|
    rm --force $temp_path
    error make $err
  }
}
