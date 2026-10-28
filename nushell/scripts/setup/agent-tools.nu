# Installs the tools coding agents reach for while they work.
export def main [] {
  use ../log.nu
  use ../nu-install
  $env.LOG_CATEGORY = "setup agent-tools"

  nu-install pacman [
    bc # Arithmetic in shell scripts
    hyperfine # Command benchmarks
    nmap # Network and service discovery
    postgresql-libs # psql, pg_isready and pg_restore
    python-jsonschema # Validating JSON configuration against schemas
    python-msgpack # msgpack-RPC probes of Neovim and RVim
    python-openpyxl # Reading xlsx files
    python-pynvim # Neovim's Python provider and its tests
    python-pyte # Reading the screen of a terminal application
    ruff # Python linter and formatter
    samply # Profiling native and Rust applications
    selene # Lua linter
    shellcheck # Shell script linter
    stylua # Lua formatter
    tcpdump # Packet captures for DNS and VPN troubleshooting
    time # Peak memory of a command through /usr/bin/time
    tmux # Driving terminal applications
    tokei # Language-aware code statistics
    xdotool # Input automation on private X11 test displays
    xorg-server-xvfb # Private X11 displays for GUI tests
  ]

  if (which dotnet | is-empty) {
    log warning "dotnet not found"
  } else {
    for tool in [ilspycmd dotnet-stack dotnet-dump seqcli] {
      if (which $tool | is-empty) {
        log info $"Installing ($tool)"
        ^dotnet tool install --global $tool
      }
    }
  }

  nu-install cargo [cargo-fuzz]

  if (which rustup | is-empty) {
    log warning "rustup not found"
  } else if (^rustup component list --installed --toolchain nightly | lines | all { $in !~ "^miri-" }) {
    log info "Installing miri"
    ^rustup component add miri --toolchain nightly
  }
}
