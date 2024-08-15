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
