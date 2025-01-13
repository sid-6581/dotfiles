export-env {
  $env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

  $env.config.completions.external.enable = true

  $env.config.completions.external.completer = {|spans|
    let expanded_alias = scope aliases | where name == $spans.0 | get 0?.expansion?

    let spans = if $expanded_alias != null  {
      $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else {
      $spans
    }

    let completions = try { ^carapace $spans.0 nushell ...$spans } catch { "[]" }
    let completions = $completions | from json

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

      let result = $formatted | try { fzf --ansi --bind 'enter:become(echo {n})' --bind 'tab:become(echo {n})' }

      if $result != null {
        [($completions | get ($result | into int))]
      } else {
        [{ value: "" }]
      }
    } else {
      null
    }
  }
}
