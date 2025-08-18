# Sets up onepassword files.
export def main [] {
  const new_custom_allowed_browsers_path = path self files/1password/custom_allowed_browsers
  ^sudo mkdir -p /etc/1password
  ^sudo cp $new_custom_allowed_browsers_path /etc/1password/custom_allowed_browsers

  mkdir ($env.HOME)/.config/rclone
  ^op --account my.1password.com read "op://Private/rclone.conf/notesPlain" | save -f ($env.HOME)/.config/rclone/rclone.conf
  ^op --account my.1password.com read "op://Private/.env/notesPlain" | save -f ($env.HOME)/.env
}
