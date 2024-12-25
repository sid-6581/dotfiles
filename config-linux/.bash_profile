export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"

has() {
  command -v "$1" 1>/dev/null 2>&1
}

if has nvidia-settings; then
  nvidia-settings --load-config-only
fi
