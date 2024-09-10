export def debug [
  message: string
  --file: string
] {
  log debug $message (ansi default_dimmed) --file $file
}

export def info [
  message: string
  --file: string
] {
  log info $message (ansi blue) --file $file
}

export def warning [
  message: string
  --file: string
] {
  log warning $message (ansi yellow) --file $file
}

export def error [
  message: string
  --file: string
] {
  log error $message (ansi red) --file $file
}

export def critical [
  message: string
  --file: string
] {
  log critical $message (ansi red_bold) --file $file
}

def log [
  level: string
  message: string
  ansi: string
  --file: string
] {
  let now = date now | format date "%Y-%m-%d %H:%M:%S"
  print --stderr $"($ansi)($now) | ($message | ansi strip)(ansi reset)"

  if $file != null {
    $"($now) | ($message | ansi strip)\n" | save -a $file
  }
}
