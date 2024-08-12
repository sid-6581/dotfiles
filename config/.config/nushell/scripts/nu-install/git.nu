use std log
use history.nu *

# Clones or updates a git repository into a destination location.
export def "nu-install git" [
  repositories: list<record<repo: string, dir: string>> # Repositories to clone
] {
  for $r in $repositories {
    if not ($r.dir | path exists) {
      log info $"Cloning ($r.repo) to ($r.dir)"
      ^git clone $r.repo $r.dir
    } else {
      cd $r.dir
      ^git fetch -q

      if (^git rev-parse HEAD) != (^git rev-parse @{u}) {
        log info $"Updating ($r.repo) in ($r.dir)"
        ^git pull
      }
    }

    nu-install history upsert [git $r.repo] {
      directory: $r.dir
    }
  }
}
