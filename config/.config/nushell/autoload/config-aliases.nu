export alias lg = lazygit

export alias n = nvim

export alias s = sudo
export alias si = sudo -i
export alias sy = sudo yazi

export alias tf = terraform
export alias tree = broot -c :pt

export alias ys = yay -S --noconfirm
export alias yss = yay -Ss
export alias yq = yay -Q
export alias yqs = yay -Qs
export alias yr = yay -R --noconfirm
export alias yrs = yay -Rs --noconfirm

export alias zj = zellij
export alias zja = zellij attach

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
