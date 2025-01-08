const RG_PREFIX = "rg --hidden --column --line-number --no-heading --color=always --smart-case"

const FZF_CMD = [
  "fzf --layout=reverse --height=~40% --ansi --preview-window=border-left --info=inline"
  "--color 'fg:#ebdbb2,bg:#1d2021,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f'"
  "--color 'info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54'"
  "--preview"
] | str join " "

const FZF_FILES = [
  "fd --hidden --color=always --type=file |"
  $"($FZF_CMD) 'bat --color=always --style=full --line-range=:500 {}'"
] | str join " "

const FZF_DIRS = [
  "fd --hidden --color=always --type=directory |"
  $"($FZF_CMD) 'lsd -al --color=always {}'"
] | str join " "

const FZF_GREP = [
  $"($FZF_CMD) 'bat --color=always --style=full --line-range=:500 {1} --highlight-line {2}'"
  $"--bind 'start:reload:($RG_PREFIX) {q} || true'"
  $"--bind 'change:reload:($RG_PREFIX) {q} || true'"
  "--bind 'enter:become(echo {1})'"
  "--delimiter :"
  "--disabled"
] | str join " "

export-env {
  $env.config.keybindings ++= [
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
    {
      name: fzf_files
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: executehostcommand
          cmd: $"
          let result = ($FZF_FILES);
          commandline edit --append $result;
          commandline set-cursor --end
          "
        }
      ]
    }
    {
      name: fzf_directory
      modifier: alt
      keycode: char_c
      mode: emacs
      event: {
        send: executehostcommand,
        cmd: $"
        let result = ($FZF_DIRS);
        commandline edit --append $result;
        commandline set-cursor --end
        "
      }
    }
    {
      name: fzf_grep
      modifier: alt
      keycode: char_g
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: executehostcommand
          cmd: $"
          let result = ($FZF_GREP);
          commandline edit --append $result;
          commandline set-cursor --end
          "
        }
      ]
    }]
}
