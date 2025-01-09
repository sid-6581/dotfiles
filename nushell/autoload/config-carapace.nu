export-env {
  $env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

  $env.config.completions.external.enable = true

  $env.config.completions.external.completer = {|spans|
    let expanded_alias = scope aliases | where name == $spans.0 | get -i 0 | get -i expansion

    let spans = if $expanded_alias != null  {
      $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else {
      $spans
    }

    let completions = ^carapace $spans.0 nushell ...$spans | from json
    let width = $completions | get value | str length | math max

    let formatted = $completions
    | each {
      (
        $"(ansi --escape ($in.style? | default { fg: green }))($in.value | fill -w $width)(ansi reset)  " ++
        $"(ansi --escape ($in.style? | default { fg: yellow }))($in.description)(ansi reset)"
      )
    }
    | str join "\n"

    let result = $formatted | try { fzf --ansi }

    if $result != null {
      [ ($result | lines | first | split row " " | first ) ]
    } else {
      [{ value: "", description: "" }]
    }
  }
}
