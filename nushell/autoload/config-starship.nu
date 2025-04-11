export-env {
  load-env {
    STARSHIP_SHELL: "nu"
    STARSHIP_CONFIG: $"($env.HOME)/.config/starship/starship.toml"
    STARSHIP_SESSION_KEY: (random chars -l 16)

    PROMPT_MULTILINE_INDICATOR: "∙ "

    PROMPT_INDICATOR: ""
    PROMPT_INDICATOR_VI_NORMAL: ""
    PROMPT_INDICATOR_VI_INSERT: ""

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
