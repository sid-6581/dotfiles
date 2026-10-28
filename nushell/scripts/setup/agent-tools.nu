# Installs the tools coding agents reach for while they work.
export def main [] {
  use ../log.nu
  use ../nu-install
  $env.LOG_CATEGORY = "setup agent-tools"

  nu-install pacman [
    bc # Arithmetic in shell scripts
    hyperfine # Command benchmarks
    postgresql-libs # psql, pg_isready and pg_restore
    python-msgpack # msgpack-RPC probes of Neovim and RVim
    python-openpyxl # Reading xlsx files
    python-pynvim # Neovim's Python provider and its tests
    python-pyte # Reading the screen of a terminal application
    ruff # Python linter and formatter
    shellcheck # Shell script linter
    time # Peak memory of a command through /usr/bin/time
    tmux # Driving terminal applications
  ]

  if (which dotnet | is-empty) {
    log warning "dotnet not found"
  } else if (which ilspycmd | is-empty) {
    log info "Installing ilspycmd"
    ^dotnet tool install --global ilspycmd
  }

  if (which rustup | is-empty) {
    log warning "rustup not found"
  } else if (^rustup component list --installed --toolchain nightly | lines | all { $in !~ "^miri-" }) {
    log info "Installing miri"
    ^rustup component add miri --toolchain nightly
  }
}
