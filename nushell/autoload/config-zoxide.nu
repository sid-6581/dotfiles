# Jump to a directory using only keywords.
export def --env z [
  ...rest: string
] {
  let arg0 = ($rest | append '~').0

  let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
    $arg0
  } else {
    (^zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n")
  }

  cd $path
}

# Jump to a directory using interactive search.
export def --env zi [
  ...rest: string
] {
  cd $'(^zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}
