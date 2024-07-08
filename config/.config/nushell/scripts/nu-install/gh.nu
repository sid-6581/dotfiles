use std log

# Downloads a release from GitHub, extracts all binaries, and copies them to the target directory.
# Uses the gh CLI, which needs to be installed.
export def "nu-install gh" [
  repo: string                    # The repo to download for (OWNER/REPO)
  pattern: string                 # The glob pattern to match (must match a single asset)
  --tag (-t): string = "Latest"   # The tag to download
  --destination (-d): string      # The destination directory (default $HOME/.local/bin)
  --process (-p): closure         # Closure to process extracted files and return a list of executables.
  --executable (-e): string       # Treat the downloaded asset as an executable with the name supplied here. Overrides --process.
] {
  let destination = $destination | default $"($env.HOME)/.local/bin/"

  let process = if $executable != null {
    {|path|
      let original = (ls $path).name.0
      let new = [$path $executable] | path join
      mv $original $new
      chmod +x $new
      [$new]
    }
  } else {
    $process | default {|path| get-executables $path }
  }

  let releases = (
    ^gh release list -R $repo
    | from tsv --noheaders --no-infer
    | rename title type tag published
    | find $tag
  )

  if ($releases | length) != 1 {
    error make { msg: $"No release found with tag ($tag)" }
  }

  # If we've already installed a release with this tag, skip the rest.
  let release = $releases | first
  let history_tag = nu-install history get [gh $repo tag]

  if $history_tag == $release.tag {
    return
  }

  log info $"Downloading executables from repo ($repo) (($release))"

  let temp_directory = mktemp -d

  let error = try {
    ^gh release download $release.tag -R $repo -p $pattern -D $temp_directory

    let asset_count = ls $temp_directory | length

    if $asset_count != 1 {
      error make { msg: $"($asset_count) assets downloaded, the glob pattern must match a single asset" }
    }

    (ls $temp_directory).name.0 | extract $in

    let executables = do $process $temp_directory

    if ($executables | length) == 0 {
      error make { msg: $"No executables found in ($temp_directory) after extracting asset" }
    }

    $executables | each { mv -f $in $destination }

    nu-install history upsert [gh $repo] {
      tag: $release.tag,
      executables: ($executables | each { path basename })
    }

    null
  } catch {|e|
    $e.raw
  }

  rm -rf $temp_directory
  $error
}

# Deletes executables installed from GitHub.
export def "nu-install gh uninstall" [
  repo: string                    # The repo to download for (OWNER/REPO)
  --destination (-d): string      # The destination directory (default $HOME/.local/bin)
] {
  let destination = $destination | default $"($env.HOME)/.local/bin/"
  let executables = nu-install history get [gh $repo executables]

  if ($executables | is-empty) {
    return
  }

  log info $"Deleting executables downloaded from repo ($repo)"

  $executables | each { rm -f ([$destination $in] | path join) }

  nu-install history remove [gh $repo]
}
