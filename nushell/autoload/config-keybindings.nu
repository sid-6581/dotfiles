export-env {
  const FZF_RG_CMD = "rg --hidden --column --line-number --no-heading --color=always --smart-case --trim"
  const FZF_BAT_CMD = "bat --color=always --style=full --line-range=:500"
  const FZF_LSD_CMD = "lsd -al --color=always"
  const FZF_FILES = $"fd --hidden --color=always --type=file | fzf --preview '($FZF_BAT_CMD) {}'"
  const FZF_DIRS = $"fd --hidden --color=always --type=directory | fzf --preview '($FZF_LSD_CMD) {}'"

  const FZF_GREP = [
    $"fzf --preview '($FZF_BAT_CMD) {1} --highlight-line {2}'"
    $"--bind 'start:reload:($FZF_RG_CMD) {q} || true'"
    $"--bind 'change:reload:($FZF_RG_CMD) {q} || true'"
    "--bind 'enter:become(echo {1})'"
    "--bind 'tab:become(echo {1})'"
    "--delimiter :"
    "--disabled"
  ] | str join " "

  $env.config.keybindings ++= [
    # Default keybindings that are just in emacs mode.
    {
      name: backspace_word
      modifier: alt
      keycode: backspace
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: backspaceword }
    }
    {
      name: move_word_left
      modifier: alt
      keycode: char_b
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordleft }
    }
    {
      name: capitalize_char
      modifier: alt
      keycode: char_c
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: capitalizechar }
    }
    {
      name: cut_word_right
      modifier: alt
      keycode: char_d
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: cutwordright }
    }
    {
      name: history_hint_word_complete
      modifier: alt
      keycode: char_f
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintwordcomplete }
          { edit: movewordright }
        ]
      }
    }
    {
      name: lowercase_word
      modifier: alt
      keycode: char_l
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: lowercaseword }
    }
    {
      name: backspace_word
      modifier: alt
      keycode: char_m
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: backspaceword }
    }
    {
      name: uppercase_word
      modifier: alt
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: uppercaseword }
    }
    {
      name: delete_word
      modifier: alt
      keycode: delete
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: deleteword }
    }
    {
      name: insert_new_line
      modifier: alt
      keycode: enter
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: insertnewline }
    }
    {
      name: move_word_left
      modifier: alt
      keycode: left
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordleft }
    }
    {
      name: history_hint_word_complete
      modifier: alt
      keycode: right
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintwordcomplete }
          { edit: movewordright }
        ]
      }
    }
    {
      name: backspace
      modifier: none
      keycode: backspace
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: backspace }
    }
    {
      name: backspace_word
      modifier: control
      keycode: backspace
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: backspaceword }
    }
    {
      name: left
      modifier: control
      keycode: char_b
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: menuleft }
          { send: left }
        ]
      }
    }
    {
      name: history_hint_complete
      modifier: control
      keycode: char_f
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintcomplete }
          { send: menuright }
          { send: right }
        ]
      }
    }
    {
      name: redo
      modifier: control
      keycode: char_g
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: redo }
    }
    {
      name: cut_to_line_end
      modifier: control
      keycode: char_k
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: cuttolineend }
    }
    {
      name: swap_graphemes
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: swapgraphemes }
    }
    {
      name: cut_from_start
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: cutfromstart }
    }
    {
      name: cut_word_left
      modifier: control
      keycode: char_w
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: cutwordleft }
    }
    {
      name: paste_cut_buffer_before
      modifier: control
      keycode: char_y
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: pastecutbufferbefore }
    }
    {
      name: undo
      modifier: control
      keycode: char_z
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: undo }
    }

    {
      name: copy_selection
      modifier: control
      keycode: insert
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: copyselection }
    }
    {
      name: cut_selection
      modifier: shift
      keycode: delete
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: cutselection }
    }
    {
      name: paste
      modifier: shift
      keycode: insert
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: paste }
    }
    # This is needed because CTRL+Backspace can get sent as CTRL+h.
    {
      name: backspace_word
      modifier: control
      keycode: char_h
      mode: [emacs, vi_normal, vi_insert]
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
    # This is needed because CTRL+j on Windows can get sent as CTRL+Enter.
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
      mode: [emacs, vi_normal, vi_insert]
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
          commandline edit --insert $result;
          "
        }
      ]
    }
    {
      name: fzf_directory
      modifier: alt
      keycode: char_c
      mode: [emacs, vi_normal, vi_insert]
      event: {
        send: executehostcommand,
        cmd: $"
        let result = try { ($FZF_DIRS) } catch { '' };
        commandline edit --insert $result;
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
          commandline edit --insert $result;
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
          cmd: "^$env.EDITOR (commandline); commandline edit ''"
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
          let result = try { $commands | fzf -q \(commandline\) } catch { '' };
          if $result != '' { commandline edit $result }
          "
        }
      ]
    }
  ]
}
