$env.config.keybindings = $env.config.keybindings ++ [
  {
    name: copy_selection
    modifier: control
    keycode: insert
    mode: emacs
    event: { edit: copyselection }
  }
  {
    name: cut_selection
    modifier: shift
    keycode: delete
    mode: emacs
    event: { edit: cutselection }
  }
  {
    name: paste
    modifier: shift
    keycode: insert
    mode: emacs
    event: { edit: paste }
  }
  # This is needed because CTRL+Backspace can get sent as CTRL+h
  {
    name: delete_one_word_backward
    modifier: control
    keycode: char_h
    mode: [emacs, vi_insert]
    event: { edit: backspaceword }
  }
  {
    name: move_up
    modifier: control
    keycode: char_k
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { send: menuup }
        { send: up }
      ]
    }
  }
  {
    name: move_down
    modifier: control
    keycode: char_j
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { send: menudown }
        { send: down }
      ]
    }
  }
  # This is needed because CTRL+j on Windows can get sent as CTRL+Enter
  {
    name: move_down
    modifier: control
    keycode: enter
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { send: menudown }
        { send: down }
      ]
    }
  }
  {
    name: completion_menu
    modifier: none
    keycode: tab
    mode: [emacs vi_normal vi_insert]
    event: {
      until: [
        { send: menu name: completion_menu }
        { send: enter }
      ]
    }
  }
  {
    name: completion_previous_menu
    modifier: shift
    keycode: backtab
    mode: [emacs, vi_normal, vi_insert]
    event: null
  }
]
