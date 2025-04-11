export-env {
  load-env {
    STARSHIP_SHELL: "nu"
    STARSHIP_CONFIG: $"($env.HOME)/.config/starship/starship.toml"
    STARSHIP_SESSION_KEY: (random chars -l 16)

    PROMPT_MULTILINE_INDICATOR: "∙ "

    PROMPT_INDICATOR: {|| prompt "" }
    PROMPT_INDICATOR_VI_NORMAL: {|| prompt ":" }
    PROMPT_INDICATOR_VI_INSERT: {|| prompt "" }

    PROMPT_COMMAND: {||
      if (which starship | is-empty) {
        return ""
      }

      let prompt = (
        ^starship prompt
        --cmd-duration $env.CMD_DURATION_MS
        $"--status=($env.LAST_EXIT_CODE)"
        --terminal-width (term size).columns
      )

      let overlays = overlay list | skip

      if ($overlays | is-not-empty) {
        $"(ansi green)\(($overlays | str join ',')\)(ansi reset) ($prompt)"
      } else {
        $prompt
      }
    }

    PROMPT_COMMAND_RIGHT: ""
  }
}

def prompt [char: string] {
  let color = if $env.LAST_EXIT_CODE? != 0 { ansi red_bold } else { ansi green_bold }
  $"($color)($char)(ansi reset) "
}
