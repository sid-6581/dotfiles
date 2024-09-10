alias lg = lazygit
alias zj = zellij
alias zja = zellij attach
alias tree = broot -c :pt
alias sudome = sudo --preserve-env=HOME
alias mc = ^mc --nosubshell
alias n = nvim
alias activate = overlay use .venv/bin/activate.nu

# LSD
alias lsd = ^lsd --color=always --icon=always --group-dirs=first --git
alias l = lsd -la
alias lz = lsd -laZ
alias lt = lsd -la --tree

# Just
alias j = just
alias gj = just --global-justfile
alias jl = just --list

# Bat
export alias b = bat
export alias bn = bat --number
export alias bnl = bat --number --line-range
export alias bp = bat --plain
export alias bpl = bat --plain --line-range
export alias bl = bat --line-range
