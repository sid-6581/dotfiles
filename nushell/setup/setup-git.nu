# Gets git username and email from the user if we don't currently have them.
# They will be saved to a file that will be autoloaded and set the environment variables.
export def --env author [] {
  let directory = $"($nu.default-config-dir)/autoload"
  let path = $"($directory)/99-GENERATED-git-username.nu"

  if ($path | path exists) {
    return
  }

  let git_username = (
    $env.GIT_AUTHOR_NAME?
    | default $env.GIT_COMMITTER_NAME?
    | if $in != null { $in } else { input "Please enter your git username: " }
  )

  let git_email = (
    $env.GIT_AUTHOR_EMAIL?
    | default $env.GIT_COMMITTER_EMAIL?
    | if $in != null { $in } else { input "Please enter your git email: " }
  )

  $env.GIT_AUTHOR_NAME = $git_username
  $env.GIT_AUTHOR_EMAIL = $git_email
  $env.GIT_COMMITTER_NAME = $git_username
  $env.GIT_COMMITTER_EMAIL = $git_email

  let contents = $"
  export-env {
  $env.GIT_AUTHOR_NAME = \"($env.GIT_AUTHOR_NAME)\"
  $env.GIT_AUTHOR_EMAIL = \"($env.GIT_AUTHOR_EMAIL)\"
  $env.GIT_COMMITTER_NAME = \"($env.GIT_COMMITTER_NAME)\"
  $env.GIT_COMMITTER_EMAIL = \"($env.GIT_COMMITTER_EMAIL)\"
  }
  "

  if (try { open -r $path }) != $contents {
    mkdir $directory
    $contents | save -f $path
  }
}
