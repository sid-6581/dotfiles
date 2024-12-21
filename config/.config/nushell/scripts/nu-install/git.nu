use log.nu
use history.nu *

# Clones or updates a git repository into a destination location.
export def "nu-install git" [
  repositories: list<record<repo: string, dir: string>> # Repositories to clone
] {
  if (which git | is-empty) {
    log warning "nu-install git: git not found"
    return
  }

  for $r in $repositories {
    if not ($r.dir | path exists) {
      log info $"nu-install git: Cloning ($r.repo) to ($r.dir)"
      ^git clone $r.repo $r.dir
    } else {
      cd $r.dir
      ^git fetch -q

      if (^git rev-parse HEAD) != (^git rev-parse @{u}) {
        log info $"nu-install git: Updating ($r.repo) in ($r.dir)"
        ^git pull
      }
    }

    nu-install history upsert [git $r.repo] {
      directory: $r.dir
    }
  }
}
