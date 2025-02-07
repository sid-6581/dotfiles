export alias jc = sudo journalctl
export alias jcl = sudo journalctl -xeu
export alias jcu = journalctl --user
export alias jcul = journalctl --user -xeu

export alias lg = lazygit

export alias n = nvim
export alias nc = nvim - -c "lua require('snacks').terminal.colorize()"

export alias s = sudo
export alias sc = sudo systemctl
export alias scdn = sudo systemctl disable --now
export alias scdr = sudo systemctl daemon-reload
export alias scen = sudo systemctl enable --now
export alias scs = sudo systemctl status
export alias scsa = sudo systemctl start
export alias scso = sudo systemctl stop
export alias scu = systemctl --user
export alias scudn = systemctl --user disable --now
export alias scudr = systemctl --user daemon-reload
export alias scuen = systemctl --user enable --now
export alias scus = systemctl --user status
export alias scusa = systemctl --user start
export alias scuso = systemctl --user stop
export alias se = sudoedit
export alias si = sudo -i
export alias sy = sudo yazi

export alias tf = terraform
export alias tree = broot -c :pt

export alias ys = yay -Syu --noconfirm
export alias yss = yay -Ss
export alias yq = yay -Q
export alias yqs = yay -Qs
export alias yr = yay -R --noconfirm
export alias yrs = yay -Rs --noconfirm

export alias zj = zellij
export alias zja = zellij attach

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
