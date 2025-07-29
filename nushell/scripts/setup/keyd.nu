# Sets up keyd.
export def main [] {
  use ../log.nu
  use ../nu-install
  $env.LOG_CATEGORY = "setup keyd"

  nu-install yay [keyd]

  log info "Writing /etc/keyd/default.conf"

  let conf = "
  [ids]
  *

  [main]
  # Maps capslock to escape when pressed and control when held.
  capslock = overload(control, esc)

  # Maps copilot key to control
  leftshift+leftmeta+f23 = rightcontrol

  [altgr]
  g = 😬
  l = 😂
  h = ❤️
  c = 😢
  "

  $conf | ^sudo tee /etc/keyd/default.conf | ignore
  ^ln -s /usr/share/keyd/keyd.compose ~/.XCompose

  log info "Starting keyd service"
  ^sudo systemctl enable --now keyd
}
