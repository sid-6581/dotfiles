#!/usr/bin/env nu

if (which nvidia-settings | is-not-empty) {
  nvidia-settings --load-config-only
}

for $remote in (rclone listremotes | lines | str replace ":" "") {
  let mount_path = $env.HOME | path join Mounts $remote

  if not ($mount_path | path exists) {
    mkdir $mount_path
  }

  rclone mount --daemon $"($remote):" $mount_path
}
