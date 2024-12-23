export-env {
  $env.config.show_banner = false
  $env.config.history.sync_on_enter = false
  $env.config.history.file_format = "sqlite"
  $env.config.history.isolation = true
  $env.config.shell_integration.osc133 = $nu.os-info.name == "linux"
  $env.config.highlight_resolved_externals = true
}
