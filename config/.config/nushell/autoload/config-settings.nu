export-env {
  $env.config.completions.algorithm = "fuzzy"
  $env.config.completions.external.max_results = 1000
  $env.config.footer_mode = "always"
  $env.config.highlight_resolved_externals = true
  $env.config.history.file_format = "sqlite"
  $env.config.history.isolation = true
  $env.config.history.sync_on_enter = false
  $env.config.rm.always_trash = true
  $env.config.shell_integration.osc133 = $nu.os-info.name == "linux"
  $env.config.show_banner = false
  $env.config.use_kitty_protocol = true
}
