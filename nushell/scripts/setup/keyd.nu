# Sets up keyd.
export def main [] {
  use ../log.nu
  use ../nu-install
  $env.LOG_CATEGORY = "setup keyd"

  nu-install paru [keyd]

  log info "Writing /etc/keyd/default.conf"

  const new_default_conf_path = path self files/keyd/default.conf
  ^sudo cp $new_default_conf_path /etc/keyd/default.conf

  ^ln -s /usr/share/keyd/keyd.compose ~/.XCompose

  log info "Starting keyd service"
  ^sudo systemctl enable --now keyd
}
