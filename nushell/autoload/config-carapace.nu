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

    let completions = ^carapace $spans.0 nushell ...$spans | from json
    let width = $completions | get value? | default "" | str length | math max

    if ($completions | length) > 0 {
      let formatted = (
        $completions
        | each {
          (
            $"(ansi --escape ($in.style? | default { fg: green }))($in.value? | default "" | fill -w $width)(ansi reset)  " ++
            $"(ansi --escape ($in.style? | default { fg: yellow }))($in.description? | default "")(ansi reset)"
          )
        }
        | str join "\n"
      )

      let result = $formatted | try { fzf --ansi }

      if $result != null {
        [{ value: ($result | lines | first | split row " " | first) }]
      } else {
        [{ value: "" }]
      }
    } else {
      null
    }
  }
}
