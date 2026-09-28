# fzf needs the terminal, so Nushell must run this completer inline.
@interactive
def carapace-fzf [place: record] {
  let completions = try {
    ^carapace $place.command.0 nushell ...$place.command | from json
  } catch { [] }

  if ($completions | length) == 1 {
    $completions
  } else if ($completions | length) > 0 {
    let width = $completions | get display? | str length | math max

    let formatted = (
      $completions
      | each {
        (
          $"(ansi --escape ($in.style? | default { fg: green }))($in.display? | default "" | fill -w $width)(ansi reset)  " ++
          $"(ansi --escape ($in.style? | default { fg: yellow }))($in.description? | default "")(ansi reset)"
        )
      }
      | str join "\n"
    )

    let result = $formatted | try { ^fzf --ansi --bind 'enter:become(echo {n})' --bind 'tab:become(echo {n})' }

    if $result != null {
      [($completions | get ($result | into int))]
    } else {
      []
    }
  } else {
    # Interactive completers must explicitly allow filename fallback.
    { completions: [], fallback: true }
  }
}

export-env {
  $env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

  $env.config.completions.external.enable = true
  $env.config.completions.external.completer = {|place| carapace-fzf $place }
}
