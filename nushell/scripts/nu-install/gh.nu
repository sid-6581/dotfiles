use log.nu
use state.nu
use utils/extract.nu
use utils/get-executables.nu
use utils/copy-executables.nu

# Downloads a release from GitHub, extracts all binaries, and copies them to
# the target directory. Uses the gh CLI, which needs to be installed.
#
# Each repo record should have the following required or optional fields:
#
# repo          The repo to download from (OWNER/REPO)
# pattern       The glob pattern to match (must match a single asset)
# tag?          The tag to download, defaults to "Latest"
# process?      Closure to process extracted files in the supplied path and return a list of executables
# executable?   Treat the downloaded asset as an executable and rename to this argument (overrides process)
export def main [
  repos: list<any>            # The repos to install
  --destination (-d): string  # The destination directory (default $HOME/.local/bin)
] {
  $env.LOG_CATEGORY = "nu-install gh"

  if (which gh | is-empty) {
    log warning "gh not found"
    return
  }

  let destination = $destination | default $"($env.HOME)/.local/bin/"

  if not ($destination | path exists) {
    log error $"($destination) does not exist"
    return
  }

  if not (^gh auth status | complete | get stdout | str contains "Logged in to") {
    log warning "Not logged into GitHub CLI, logging in"
    ^gh auth login
  }

  for $r in $repos {
    let tag = $r.tag? | default "Latest"

    let releases = (
      ^gh release list -R $r.repo
      | from tsv --noheaders --no-infer
      | rename title type tag published
      | find $tag
    )

    if ($releases | length) != 1 {
      log error $"No release found with tag ($tag)"
      return
    }

    # If we've already installed a release with this tag, skip the rest.
    let release = $releases | first
    let history_tag = state history get ["gh" $r.repo "tag"]
    if $history_tag == $release.tag {
      continue
    }

    log info $"Downloading executables from repo ($r.repo) (($release))"

    let temp_directory = mktemp -d

    try {
      ^gh release download $release.tag -R $r.repo -p $r.pattern -D $temp_directory

      let asset_count = ls $temp_directory | length
      if $asset_count != 1 {
        log error $"($asset_count) assets downloaded from ($r.repo), the glob pattern must match a single asset"
        continue
      }

      extract (ls $temp_directory).0.name
      let executables = process $r $temp_directory
      copy-executables $executables $destination

      state history upsert ["gh" $r.repo] {
        tag: $release.tag
        executables: ($executables | each { path basename })
      }
    } catch {|e|
      log error $"Error downloading assets from ($r.repo): ($e.msg)"
    }

    rm -rf $temp_directory
  }
}

# Deletes executables installed from GitHub.
export def uninstall [
  repo: string                    # The repo to download for (OWNER/REPO)
  --destination (-d): string      # The destination directory (default $HOME/.local/bin)
] {
  let destination = $destination | default ($env.HOME | path join .local bin)
  let executables = state history get ["gh" $repo "executables"]

  if ($executables | is-empty) {
    return
  }

  log info $"Deleting executables downloaded from repo ($repo)"

  $executables | each { rm -f ([$destination $in] | path join) }

  state history remove ["gh" $repo]
}

# Process extracted files in temp directory and return a list of the executables to keep.
def process [
  repo: any
  path: string
]: nothing -> list<string> {
  if $repo.executable? != null {
    let original = (ls $path).name.0
    let new = [$path $repo.executable] | path join
    mv $original $new

    if $nu.os-info.name == "linux" {
      ^chmod +x $new
    }

    return [$new]
  }

  if $repo.process? != null {
    return (do $repo.process $path)
  }

  get-executables $path
}
