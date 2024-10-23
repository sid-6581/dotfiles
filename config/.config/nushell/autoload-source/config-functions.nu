use ../autoload-modules/config-git-aliases.nu *

# Git simple PR:
#
# - Runs pre-commit on all files, if needed.
# - Commits all changes
# - Creates a new branch with the provided name
# - Commits the changes with the provided commit message
def gspr [
  branch: string  # Branch name
  message: string # Commit messages
] {
  if (git_current_branch) != (git_main_branch) {
    error make { msg: "Must be in main branch" }
  }

  if ("./.github/workflows/pre-commit.yml" | path exists) {
    ^pre-commit run --all-files
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
def --wrapped gh-clone [
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
def --wrapped gh-fork [
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

# Does a podman system prune.
def pm-gc [] {
  ^podman system prune -a -f
}

# Runs a podman container with bash as the entrypoint.
def pm-bash [
  image: string # The name of the image to run
] {
  ^podman run -it --replace --entrypoint /usr/bin/env --name $image $image bash
}

# Runs a podman container with optional command arguments.
def pm-run [
  image: string      # The name of the image to run
  ...command: string # The command to run
] {
  ^podman run -it --replace --name $image $image ...$command
}
