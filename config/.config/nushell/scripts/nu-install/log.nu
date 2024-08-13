export def debug [
  message: string
] {
  print --stderr $"(ansi default_dimmed)($message)"
}

export def info [
  message: string
] {
  print --stderr $"(ansi blue)($message)"
}

export def warning [
  message: string
] {
  print --stderr $"(ansi yellow)($message)"
}

export def error [
  message: string
] {
  print --stderr $"(ansi red)($message)"
}

export def critical [
  message: string
] {
  print --stderr $"(ansi red_bold)($message)"
}
