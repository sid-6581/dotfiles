use std
use log.nu
use history.nu *

const category = "nu-install link"

# Creates a symbolic link to a file or all files in a directory, recursively.
export def "nu-install link" [
  links: list<record<target: string, link: string>> # Links to create
] {
  for $l in $links {
    let target_type = $l.target | path type
    let target = $l.target | path expand --no-symlink
    let link = $l.link | path expand --no-symlink

    if $target_type == null {
      log warning -c $category $"($target) does not exist"
      return
    }

    if ($target_type == "dir") and (not ($link | path exists)) {
      mkdir $link
    }

    if ($target_type == "dir") != (($link | path type) == "dir") {
      log error -c $category $"Both ($target) and ($link) must be either a directory or a file"
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
export def "nu-install link clean" [] {
  let links = nu-install history get [link] | transpose key value

  for $link in $links {
    if not ($link.key | path exists -n) {
      log info -c $category $"Removing history for missing link at ($link.key)"
      nu-install history remove [link $link.key]
    } else {
      let actual_target = (ls -al $link.key | where type == symlink).target?.0?
      if $actual_target != null and not ($actual_target | path exists) {
        log info -c $category $"Removing broken link at ($link.key) to ($actual_target)"
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
  if (try { (ls -al $link).0.target }) != $target {
    log info -c $category $"Creating link to ($target) at ($link)"

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

  nu-install history upsert [link $link] {
    target: $target
  }
}
