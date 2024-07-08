use std log

# Clones or updates a git repository into a destination location.
export def "nu-install git" [
  repository: string # Repository to clone
  directory: string  # Directory to clone repository to
] {
  if not ($directory | path exists) {
    log info $"Cloning ($repository) to ($directory)"
    ^git clone $repository $directory
  } else {
    cd $directory
    ^git fetch -q

    if (^git rev-parse HEAD) != (^git rev-parse @{u}) {
      log info $"Updating ($repository) in ($directory)"
      ^git pull
    }
  }

  nu-install history upsert [git $repository] {
    directory: $directory
  }
}
