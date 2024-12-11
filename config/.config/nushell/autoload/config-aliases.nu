export alias lg = lazygit
export alias zj = zellij
export alias zja = zellij attach
export alias tree = broot -c :pt
export alias sudome = sudo --preserve-env=HOME
export alias mc = ^mc --nosubshell
export alias n = nvim
export alias activate = overlay use .venv/bin/activate.nu

# LSD
export alias lsd = ^lsd --color=always --icon=always --group-dirs=first --git
export alias l = lsd -la
export alias lz = lsd -laZ
export alias lt = lsd -la --tree

# Just
export alias j = just
export alias gj = just --global-justfile
export alias jl = just --list

# Bat
export alias b = bat
export alias bn = bat --number
export alias bnl = bat --number --line-range
export alias bp = bat --plain
export alias bpl = bat --plain --line-range
export alias bl = bat --line-range
