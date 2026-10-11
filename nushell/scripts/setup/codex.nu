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

# Updates and installs ChatGPT Community with the dotfiles' Linux features.
export def install [] {
  use ../log.nu
  $env.LOG_CATEGORY = "setup codex install"

  if $nu.os-info.name != "linux" {
    error make { msg: "ChatGPT Community installation requires Linux" }
  }

  const repository_url = "https://github.com/ilysenko/codex-desktop-linux.git"
  const features_path = path self files/codex/linux-features.json
  let repository_dir = $env.HOME | path join Code Personal codex-desktop-linux

  if ($repository_dir | path exists) {
    if not ($repository_dir | path join .git | path exists) {
      error make { msg: $"($repository_dir) exists but is not a Git checkout" }
    }

    let branch = do --capture-errors { ^git -C $repository_dir branch --show-current } | str trim
    if $branch != "main" {
      error make { msg: $"($repository_dir) must be on main before installing" }
    }

    log info $"Updating ($repository_dir)"
    do --capture-errors { ^git -C $repository_dir pull --ff-only origin main }
  } else {
    mkdir ($repository_dir | path dirname)
    log info $"Cloning ($repository_url) to ($repository_dir)"
    do --capture-errors { ^git clone --branch main --single-branch $repository_url $repository_dir }
  }

  let config_path = $repository_dir | path join linux-features features.json
  let config = if ($config_path | path exists) { open $config_path } else { {} }
  let features = open $features_path
  $config | merge $features | to json --indent 2 | save --force $config_path

  # Keep package extraction on disk: /tmp is RAM-backed on this machine.
  let cache_home = $env.XDG_CACHE_HOME? | default ($env.HOME | path join .cache)
  let build_tmp = $cache_home | path join codex-desktop-dev tmp
  mkdir $build_tmp

  log info $"Installing with features: ($features.enabled | str join ', ')"
  cd $repository_dir
  with-env {
    TMPDIR: $build_tmp
    CARGO_TARGET_DIR: ($repository_dir | path join target)
    CODEX_LINUX_FEATURES_ROOT: ($repository_dir | path join linux-features)
    CODEX_LINUX_FEATURES_CONFIG: $config_path
    PATH: ($env.PATH | prepend ($env.HOME | path join .cargo bin) | uniq)
  } {
    do --capture-errors { ^make install-native MAX_BUILD_THREADS=8 }
  }

  log info "Installed ChatGPT Community. Fully quit and reopen it to load the new version."
}
