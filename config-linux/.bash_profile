has() {
  command -v "$1" 1>/dev/null 2>&1
}

[[ -f "$HOME/.profile" ]] && . "$HOME/.profile"
[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
[[ -f "$HOME/.bash_profile.local" ]] && . "$HOME/.bash_profile.local"
[[ -f "$HOME/.bash_profile.nu" ]] && has nu && nu "$HOME/.bash_profile.nu"
[[ -f "$HOME/.bash_profile.local.nu" ]] && has nu && nu "$HOME/.bash_profile.nu"
