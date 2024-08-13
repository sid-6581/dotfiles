export use nu-install/log.nu *

# The log file to use for writing update logs.
export def update-file [] {
  let directory = $"($env.HOME)/.local/state/dotfiles"
  if not ($directory | path exists) {
    mkdir directory
  }
  [$directory $"updates-(date now | format date "%Y-%m-%d").log"] | path join
}
