[[ -f "$HOME/.profile" ]] && . .profile

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"
export GOPATH="$HOME/.go"

has() {
  command -v "$1" 1>/dev/null 2>&1
}

[[ -f "$HOME/.bash_profile.nu" ]] && has nu && nu .bash_profile.nu &
