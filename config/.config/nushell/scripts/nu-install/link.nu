use std log

# Creates a symbolic link to a file or all files in a directory, recursively.
export def "nu-install link" [
  target: string # Path to existing file or directory
  link: string   # Path to new link
] {
  let target_type = $target | path type

  if ($target_type == dir) and (not ($link | path exists)) {
    mkdir $link
  }

  if ($target_type == dir) != (($link | path type) == dir) {
    error make { msg: $"Both ($target) and ($link) must be either a directory or a file" }
  }

  if $target_type == dir {
    let target_files = glob --no-dir $"($target)/**"
    let target = $target | path expand

    for $target_file in $target_files {
      let target_file = $target_file | path expand
      let target_relative = $target_file | str substring (($target | str length) + 1)..
      link $target_file ([$link $target_relative] | path join)
    }
  } else {
    link $target $link
  }
}

# Cleans links that are no longer valid.
export def "nu-install link clean" [] {
  let links = nu-install history get [link] | transpose key value

  for $link in $links {
    if not ($link.key | path exists -n) {
      log info $"Removing history for missing link at ($link.key)"
      nu-install history remove [link $link.key]
    } else {
      let actual_target = (ls -al $link.key | where type == symlink).target?.0?
      if $actual_target != null and not ($actual_target | path exists) {
        log info $"Removing broken link at ($link.key) to ($actual_target)"
        ^rm -rf $link.key
        nu-install history remove [link $link.key]
      }
    }
  }
}

def link [
  target: string # Path to existing file
  link: string   # Path to new link
] {
  if (do -i { (ls -al $link).target.0 }) != $target {
    log info $"Creating link to ($target) at ($link)"

    let parent = $link | path dirname

    if not ($parent | path exists --no-symlink) {
      mkdir ($link | path dirname)
    }

    ^ln -sfT $target $link
  }

  nu-install history upsert [link $link] {
    target: $target
  }
}
