const FZF_RG_CMD = "rg --hidden --column --line-number --no-heading --color=always --smart-case"
const FZF_BAT_CMD = "bat --color=always --style=full --line-range=:500"
const FZF_LSD_CMD = "lsd -al --color=always"
const FZF_FILES = $"fd --hidden --color=always --type=file | fzf --preview '($FZF_BAT_CMD) {}'"
const FZF_DIRS = $"fd --hidden --color=always --type=directory | fzf --preview '($FZF_LSD_CMD) {}'"

const FZF_GREP = [
  $"fzf --preview '($FZF_BAT_CMD) {1} --highlight-line {2}'"
  $"--bind 'start:reload:($FZF_RG_CMD) {q} || true'"
  $"--bind 'change:reload:($FZF_RG_CMD) {q} || true'"
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
          let result = try { ($FZF_FILES) } catch { '' };
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
        let result = try { ($FZF_DIRS) } catch { '' };
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
          let result = try { ($FZF_GREP) } catch { '' };
          commandline edit --append $result;
          commandline set-cursor --end
          "
        }
      ]
    }
    {
      name: quote
      modifier: control
      keycode: char_q
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: executehostcommand
          cmd: "commandline edit ('\"' ++ (commandline) ++ '\"')"
        }
      ]
    }
    {
      name: edit
      modifier: alt
      keycode: char_e
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: executehostcommand
          cmd: "commandline edit ('exec $env.EDITOR \"' ++ (commandline) ++ '\"')"
        }
      ]
    }
    {
      name: fzf_history
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: executehostcommand
          cmd: $"
          let commands = history | sort-by -r start_timestamp | get command | uniq | each { $in | nu-highlight } | str join \(char newline\);
          let result = try { $commands | fzf } catch { '' };
          commandline edit $result
          "
        }
      ]
    }
  ]
}
