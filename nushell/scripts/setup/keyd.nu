# Sets up keyd.
export def main [] {
  use ../log.nu
  use ../nu-install
  $env.LOG_CATEGORY = "setup keyd"

  nu-install paru [keyd]

  const new_conf_path = path self files/keyd

  for path in (ls $new_conf_path | get name) {
    let filename = $path | path basename

    log info $"Writing /etc/keyd/($filename)"

    ^sudo cp $path $"/etc/keyd/($filename)"
  }

  ^ln -sf /usr/share/keyd/keyd.compose ~/.XCompose

  log info "Starting keyd service"
  ^sudo systemctl enable --now keyd
}
