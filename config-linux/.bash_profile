export PATH="$HOME/.local/bin:$PATH"

if [[ $- == *i* && -f "$HOME/.local/bin/nu" ]]; then
  export SHELL="$HOME/.local/bin/nu"
  exec nu -li
fi
