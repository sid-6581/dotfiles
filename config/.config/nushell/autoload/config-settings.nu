export-env {
  $env.config.completions.external.max_results = 1000
  $env.config.footer_mode = "always"
  $env.config.highlight_resolved_externals = true
  $env.config.history.file_format = "sqlite"
  $env.config.history.isolation = true
  $env.config.history.sync_on_enter = false
  $env.config.rm.always_trash = true
  $env.config.shell_integration.osc133 = $nu.os-info.name == "linux"
  $env.config.show_banner = false
  $env.config.use_kitty_protocol = false

  $env.config.menus ++= [
    {
      name: help_menu
      only_buffer_difference: true    # Search is done on the text written after activating the menu
      marker: ""                      # Indicator that appears with the menu is active
      type: {
        layout: description           # Type of menu
        columns: 4                    # Number of columns where the options are displayed
        col_width: 20                 # Optional value. If missing all the screen width is used to calculate column width
        col_padding: 2                # Padding between columns
        selection_rows: 10             # Number of rows allowed to display found options
        description_rows: 20          # Number of rows allowed to display command description
      }
      style: {
        text: green                   # Text style
        selected_text: green_reverse  # Text style for selected option
        description_text: yellow      # Text style for description
      }
    }
    {
      name: completion_menu
      only_buffer_difference: false   # Search is done on the text written after activating the menu
      marker: ""                      # Indicator that appears with the menu is active
      type: {
        layout: columnar              # Type of menu
        columns: 1                    # Number of columns where the options are displayed
        col_padding: 2                # Padding between columns
      }
      style: {
        text: green                   # Text style
        selected_text: green_reverse  # Text style for selected option
        description_text: yellow      # Text style for description
      }
    }
    {
      name: history_menu
      only_buffer_difference: false   # Search is done on the text written after activating the menu
      marker: ""                      # Indicator that appears with the menu is active
      type: {
        layout: list                  # Type of menu
        page_size: 40                 # Number of entries that will presented when activating the menu
      }
      style: {
        text: green                   # Text style
        selected_text: green_reverse  # Text style for selected option
        description_text: yellow      # Text style for description
      }
    }
  ]
}
