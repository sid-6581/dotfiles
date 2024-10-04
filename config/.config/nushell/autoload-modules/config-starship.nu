# this file is both a valid
# - overlay which can be loaded with `overlay use starship.nu`
# - module which can be used with `use starship.nu`
# - script which can be used with `source starship.nu`
export-env {
  load-env {
    STARSHIP_SHELL: "nu"
    STARSHIP_CONFIG: $"($env.HOME)/.config/starship/starship.toml"
    STARSHIP_SESSION_KEY: (random chars -l 16)

    PROMPT_MULTILINE_INDICATOR: (
      if (which starship | is-not-empty) {
        ^starship prompt --continuation
      } else {
        "::: "
      }
    )

    PROMPT_INDICATOR: ""

    PROMPT_COMMAND: {||
      if (which starship | is-empty) {
        return ""
      }

      let prompt = (
        ^starship prompt
        --cmd-duration $env.CMD_DURATION_MS
        $"--status=($env.LAST_EXIT_CODE)"
        --terminal-width (term size).columns
      ) | lines

      let prefix_top = $"(ansi blue)┌ (ansi reset)"
      let prefix_bottom = $"(ansi blue)└ (ansi reset)"

      print $"($prefix_top)($prompt.0?)"

      let overlays = overlay list | skip

      if ($overlays | is-not-empty) {
        $"($prefix_bottom)(ansi green)\(($overlays | str join ',')\)(ansi reset) ($prompt.1?)"
      } else {
        $"($prefix_bottom)($prompt.1?)"
      }
    }

    PROMPT_COMMAND_RIGHT: ""
  }
}
