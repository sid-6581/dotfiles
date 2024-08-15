use log.nu
use history.nu *
use utils/extract.nu
use utils/get-executables.nu

# Downloads a release from GitHub, extracts all binaries, and copies them to the target directory.
# Uses the gh CLI, which needs to be installed.
#
# Each repo record should have the following required or optional fields:
#
# repo          The repo to download from (OWNER/REPO)
# pattern       The glob pattern to match (must match a single asset)
# tag?          The tag to download, defaults to "Latest"
# process?      Closure to process extracted files in the supplied path and return a list of executables
# executable?   Treat the downloaded asset as an executable and rename to this argument (overrides process)
export def "nu-install gh" [
  repos: list<any>            # The repos to install
  --destination (-d): string  # The destination directory (default $HOME/.local/bin)
] {
  if (which gh | is-empty) {
    log error "gh not found, skipping nu-install gh"
    return
  }

  let destination = $destination | default $"($env.HOME)/.local/bin/"

  if not (gh auth status o+e>| str contains "Logged in to") {
    log error "Not logged into GitHub CLI, logging in"
    ^gh auth login
  }

  # TODO: Do gh version checks in parallel.

  for $r in $repos {
    let tag = $r.tag? | default "Latest"

    let releases = (
      ^gh release list -R $r.repo
      | from tsv --noheaders --no-infer
      | rename title type tag published
      | find $tag
    )

    if ($releases | length) != 1 {
      error make { msg: $"No release found with tag ($tag)" }
    }

    # If we've already installed a release with this tag, skip the rest.
    let release = $releases | first
    let history_tag = nu-install history get [gh $r.repo tag]

    if $history_tag == $release.tag {
      continue
    }

    log info $"Downloading executables from repo ($r.repo) (($release))"

    let temp_directory = mktemp -d

    let error = try {
      ^gh release download $release.tag -R $r.repo -p $r.pattern -D $temp_directory

      let asset_count = ls $temp_directory | length

      if $asset_count != 1 {
        error make { msg: $"($asset_count) assets downloaded, the glob pattern must match a single asset" }
      }

      (ls $temp_directory).name.0 | extract $in

      let executables = process $r $temp_directory

      if ($executables | length) == 0 {
        error make { msg: $"No executables found in ($temp_directory) after extracting asset" }
      }

      # Copy executables to the destination.
      for $executable in $executables {
        let file_name = $executable | path basename
        let destination_file = [$destination $file_name] | path join

        # This is necessary for Windows since running executables can't be replaced.
        if $nu.os-info.name != "linux" and ($destination_file | path exists) {
          mv -f $destination_file ([$nu.temp-path $"($file_name).bak"] | path join)
        }

        mv -f $executable $destination_file
      }

      nu-install history upsert [gh $r.repo] {
        tag: $release.tag
        executables: ($executables | each { path basename })
      }

      null
    } catch {|e|
      $e.raw?
    }

    rm -rf $temp_directory
    $error
  }
}

# Deletes executables installed from GitHub.
export def "nu-install gh uninstall" [
  repo: string                    # The repo to download for (OWNER/REPO)
  --destination (-d): string      # The destination directory (default $HOME/.local/bin)
] {
  let destination = $destination | default ([$env.HOME ".local/bin/"] | path join)
  let executables = nu-install history get [gh $repo executables]

  if ($executables | is-empty) {
    return
  }

  log info $"Deleting executables downloaded from repo ($repo)"

  $executables | each { rm -f ([$destination $in] | path join) }

  nu-install history remove [gh $repo]
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
