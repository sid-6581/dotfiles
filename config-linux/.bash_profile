export PATH="$HOME/.local/bin:$PATH"

has() {
  command -v "$1" 1>/dev/null 2>&1
}

if [[ $- == *i* ]] && has nu; then
  export SHELL="nu"
  exec nu -li
fi
