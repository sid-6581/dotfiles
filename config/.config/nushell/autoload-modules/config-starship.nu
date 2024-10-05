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

      if $env.PROMPT_RENDERED? == true {
        print ""
      }

      let prompt = (
        ^starship prompt
        --cmd-duration $env.CMD_DURATION_MS
        $"--status=($env.LAST_EXIT_CODE)"
        --terminal-width (term size).columns
      ) | lines

      let overlays = overlay list | skip

      # We manually print the first line of the prompt because of a bug in reedline.
      # If we don't do this, the prompt will be redrawn one line lower after a terminal resize.
      if ($overlays | is-not-empty) {
        print $"(ansi green)\(($overlays | str join ',')\)(ansi reset) ($prompt.0?)"
      } else {
        print $"($prompt.0?)"
      }

      $prompt.1?
    }

    PROMPT_COMMAND_RIGHT: ""
  }
}
