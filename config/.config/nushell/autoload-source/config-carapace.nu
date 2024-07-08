$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

let carapace_completer = {|spans|
  let expanded_alias = scope aliases | where name == $spans.0 | get -i 0 | get -i expansion

  let spans = if $expanded_alias != null  {
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  }

  carapace $spans.0 nushell ...$spans | from json
}

mut current = ($env | default {} config).config | default {} completions

$current.completions = ($current.completions | default {} external)

$current.completions.external = (
  $current.completions.external
  | default true enable
  | default $carapace_completer completer
)

$env.config = $current
