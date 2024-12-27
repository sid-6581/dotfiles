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

    ^carapace $spans.0 nushell ...$spans | from json
  }
}
