# Sets up onepassword files.
export def main [] {
  ^op --account my.1password.com read "op://Private/rclone.conf/notesPlain" | save -f ($env.HOME)/.config/rclone/rclone.conf
  ^op --account my.1password.com read "op://Private/.env/notesPlain" | save -f ($env.HOME)/.env
}
