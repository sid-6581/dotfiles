# Opens vifm with TERM=kitty-direct.
export def v [] {
  $env.TERM = "kitty-direct"
  ^vifm
}

# Creates a new directory and cds to it.
export def --env mcd [
  dir: string # The directory to create
] {
  mkdir $dir
  cd $dir
}

# Gets a less cluttered $env.
export def nv [] {
  $env | reject config LS_COLORS ENV_CONVERSIONS PROMPT_COMMAND PROMPT_COMMAND_RIGHT PROMPT_INDICATOR PROMPT_MULTILINE_INDICATOR
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
