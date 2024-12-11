# Default menus:
# 0: completion_menu
# 1: ide_completion_menu
# 2: history_menu
# 3: help_menu
export-env {
  $env.config = (
    $env.config
    | upsert menus.0.marker ""
    | upsert menus.0.type.columns 1
    | reject menus.0.type.col_width
    | upsert menus.1.marker ""
    | upsert menus.2.marker ""
    | upsert menus.2.only_buffer_difference false
    | upsert menus.3.marker ""
    | upsert menus.3.type.columns 1
    | reject menus.3.type.col_width
  )
}
