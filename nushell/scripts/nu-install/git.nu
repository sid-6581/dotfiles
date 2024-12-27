use log.nu
use state.nu

const category = "nu-install git"

# Clones or updates a git repository into a destination location.
export def main [
  repositories: list<record<repo: string, dir: string>> # Repositories to clone
] {
  if (which git | is-empty) {
    log warning -c $category "git not found"
    return
  }

  for $r in $repositories {
    if not ($r.dir | path exists) {
      log info -c $category $"Cloning ($r.repo) to ($r.dir)"
      ^git clone $r.repo $r.dir
    } else {
      cd $r.dir
      ^git fetch -q

      if (^git rev-parse HEAD) != (^git rev-parse @{u}) {
        log info -c $category $"Updating ($r.repo) in ($r.dir)"
        ^git pull
      }
    }

    state history upsert ["git" $r.repo] {
      directory: $r.dir
    }
  }
}
