use std
use log.nu
use state.nu

# Creates a symbolic link to a file or all files in a directory, recursively.
export def main [
  links: list<record<target: string, link: string>> # Links to create
] {
  $env.LOG_CATEGORY = "nu-install link"

  for $l in $links {
    let target_type = $l.target | path type
    let target = $l.target | path expand --no-symlink
    let link = $l.link | path expand --no-symlink

    if $target_type == null {
      log warning $"($target) does not exist"
      return
    }

    if ($target_type == "dir") and (not ($link | path exists)) {
      mkdir $link
    }

    if ($target_type == "dir") != (($link | path type) == "dir") {
      log error $"Both ($target) and ($link) must be either a directory or a file"
      return
    }

    if $target_type == "dir" {
      let target_files = do {
        cd $target
        glob --no-dir **
      }

      for $target_file in $target_files {
        let target_file = $target_file
        let target_relative = $target_file | str substring (($target | str length) + 1)..
        link $target_file ([$link $target_relative] | path join)
      }
    } else {
      link $target $link
    }
  }
}

# Cleans links that are no longer valid.
export def clean [] {
  $env.LOG_CATEGORY = "nu-install link clean"

  let links = state history get ["link"]

  if $links == null {
    return
  }

  for $link in ($links | transpose key value) {
    if not ($link.key | path exists -n) {
      log info $"Removing history for missing link at ($link.key)"
      state history remove ["link" $link.key]
    } else {
      let actual_target = (ls -al $link.key | where type == symlink).target?.0?
      if $actual_target != null and not ($actual_target | path exists) {
        log info $"Removing broken link at ($link.key) to ($actual_target)"
        ^rm -rf $link.key
        state history remove ["link" $link.key]
      }
    }
  }
}

def link [
  target: string # Path to existing file
  link: string   # Path to new link
] {
  $env.LOG_CATEGORY = "nu-install link"

  if (try { (ls -al $link).0.target }) != $target {
    log info $"Creating link to ($target) at ($link)"

    let parent = $link | path dirname

    if not ($parent | path exists --no-symlink) {
      mkdir ($link | path dirname)
    }

    if $nu.os-info.name == "linux" {
      ^ln -sfT $target $link
    } else {
      cd $env.HOME
      rm -f $link
      ^mklink $link $target o> (std null-device)
    }
  }

  state history upsert ["link" $link] {
    target: $target
  }
}
