export def debug [
  message: string
  --category (-c): string
  --file (-f): string
] {
  log debug $message (ansi default_dimmed) --category $category --file $file
}

export def info [
  message: string
  --category (-c): string
  --file (-f): string
] {
  log info $message (ansi blue) --category $category --file $file
}

export def warning [
  message: string
  --category (-c): string
  --file (-f): string
] {
  log warning $message (ansi yellow) --category $category --file $file
}

export def error [
  message: string
  --category (-c): string
  --file (-f): string
] {
  log error $message (ansi red) --category $category --file $file
}

export def critical [
  message: string
  --category (-c): string
  --file (-f): string
] {
  log critical $message (ansi red_bold) --category $category --file $file
}

def log [
  level: string
  message: string
  ansi: string
  --category (-c): string
  --file (-f): string
] {
  let now = date now | format date "%Y-%m-%d %H:%M:%S"
  let category = $category | default "" | str substring ..19 | fill -w 20
  print --stderr $"($ansi)($now) | ($category) | ($message | ansi strip)(ansi reset)"

  if $file != null {
    $"($now) | ($category) | ($message | ansi strip)\n" | save -a $file
  }
}