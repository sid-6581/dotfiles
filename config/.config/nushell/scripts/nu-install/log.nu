export def debug [
  message: string
] {
  log debug $message (ansi default_dimmed)
}

export def info [
  message: string
] {
  log info $message (ansi blue)
}

export def warning [
  message: string
] {
  log warning $message (ansi yellow)
}

export def error [
  message: string
] {
  log error $message (ansi red)
}

export def critical [
  message: string
] {
  log critical $message (ansi red_bold)
}

def log [
  level: string
  message: string
  ansi: string
] {
  let now = date now | format date "%Y-%m-%d %H:%M:%S"
  print --stderr $"($ansi)($now) | ($message)(ansi reset)"
}
