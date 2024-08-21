#!/usr/bin/env nu

# Gets git username and email from the user if we don't currently have them in environment variables.
# They will be saved to a file that will be autoloaded and set the environment variables.
export def --env author [] {
  let directory = $"($nu.default-config-dir)/autoload-source"
  let path = $"($directory)/99-GENERATED-git-username.nu"

  if ($path | path exists) {
    return
  }

  let git_username = $env.GIT_AUTHOR_NAME? | default $env.GIT_COMMITTER_NAME? | if $in != null { $in } else { input "Please enter your git username: " }
  let git_email = $env.GIT_AUTHOR_EMAIL? | default $env.GIT_COMMITTER_EMAIL? | if $in != null { $in } else { input "Please enter your git username: " }

  $env.GIT_AUTHOR_NAME = $git_username
  $env.GIT_AUTHOR_EMAIL = $git_email
  $env.GIT_COMMITTER_NAME = $git_username
  $env.GIT_COMMITTER_EMAIL = $git_email

  mkdir $"($nu.default-config-dir)/autoload-source"

  let contents = $"
  $env.GIT_AUTHOR_NAME = "($env.GIT_AUTHOR_NAME)"
  $env.GIT_AUTHOR_EMAIL = "($env.GIT_AUTHOR_EMAIL)"
  $env.GIT_COMMITTER_NAME = "($env.GIT_COMMITTER_NAME)"
  $env.GIT_COMMITTER_EMAIL = "($env.GIT_COMMITTER_EMAIL)"
  "

  if (do -i { open -r $path }) != $contents {
    $contents | save -f $path
  }
}
