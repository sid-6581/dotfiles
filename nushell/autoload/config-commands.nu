# Creates a new directory and cds to it.
export def --env mcd [
  dir: string # The directory to create
] {
  mkdir $dir
  cd $dir
}

# Git simple PR:
#
# - Runs pre-commit on all files, if needed.
# - Commits all changes
# - Creates a new branch with the provided name
# - Commits the changes with the provided commit message
export def gspr [
  branch: string  # Branch name
  message: string # Commit messages
] {
  use config-git-aliases.nu *

  if (git_current_branch) != (git_main_branch) {
    error make { msg: "Must be in main branch" }
  }

  # Run pre-commit, and if it fails, try running again.
  # The first pass may be able to auto-fix the files.
  if ("./.github/workflows/pre-commit.yml" | path exists) {
    let result = ^pre-commit run --all-files | complete
    if $result.exit_code != 0 {
      ^pre-commit run --all-files
    }
  }

  ^git add .
  ^git switch -c $branch
  ^git commit -m $message
  ^git push origin (git_current_branch)
  ^gh pr create --fill
  ^gh pr merge --admin --squash
  ^git switch (git_main_branch)
  ^git pull
  ^git branch -D $branch
}

# Searches for a GitHub repo and clones it.
export def --wrapped gh-clone [
  ...query: string
] {
  let results = do -c { ^gh search repos ...$query --json fullName,description }

  let repo = $results
  | from json
  | select fullName description
  | insert name { $"($in.fullName | fill -w 50) ($in.description)" }
  | input list --fuzzy -d name
  | get -i fullName

  if $repo == null {
    return
  }

  if ($repo | is-empty) {
    error make { msg: "No repos found" }
  }

  ^gh repo clone $repo
}

# Searches for a GitHub repo and forks it.
export def --wrapped gh-fork [
  ...query: string
] {
  let results = do -c { ^gh search repos ...$query --json fullName,description }

  let repo = $results
  | from json
  | select fullName description
  | insert name { $"($in.fullName | fill -w 50) ($in.description)" }
  | input list --fuzzy -d name
  | get -i fullName

  if $repo == null {
    return
  }

  if ($repo | is-empty) {
    error make { msg: "No repos found" }
  }

  ^gh repo fork $repo
}

# Performs a podman system prune.
export def pm-gc [] {
  ^podman system prune -a -f
}

# Runs a podman container with bash as the entrypoint.
export def pm-bash [
  image: string # The name of the image to run
] {
  ^podman run -it --replace --entrypoint /usr/bin/env --name $image $image bash
}

# Runs a podman container with optional command arguments.
export def pm-run [
  image: string      # The name of the image to run
  ...command: string # The command to run
] {
  ^podman run -it --replace --name $image $image ...$command
}

# Gets a less cluttered $env.
export def nv [] {
  $env | reject config LS_COLORS ENV_CONVERSIONS PROMPT_COMMAND PROMPT_COMMAND_RIGHT PROMPT_INDICATOR PROMPT_MULTILINE_INDICATOR
}

# Mounts a kio-fuse URL.
export def kio-mount [
  url: string # The URL to mount
] {
  (
    ^dbus-send --session --print-reply --type=method_call
    --dest=org.kde.KIOFuse
    /org/kde/KIOFuse
    org.kde.KIOFuse.VFS.mountUrl $"string:($url)"
  )
}
