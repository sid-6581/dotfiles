export alias b = bat
export alias bl = bat --line-range
export alias bn = bat --number
export alias bnl = bat --number --line-range
export alias bp = bat --plain
export alias bpl = bat --plain --line-range
export alias gj = just --global-justfile
export alias j = just
export alias jc = sudo journalctl
export alias jcl = sudo journalctl -xeu
export alias jcu = journalctl --user
export alias jcul = journalctl --user -xeu
export alias jl = just --list
export alias k = kubectl
export alias lg = lazygit
export alias mc = mcli
export alias n = nvim
export alias nc = nvim - -c "lua require('util.winbuf').colorize()"
export alias s = sudo
export alias sc = sudo systemctl
export alias scdn = sudo systemctl disable --now
export alias scdr = sudo systemctl daemon-reload
export alias scen = sudo systemctl enable --now
export alias scr = sudo systemctl restart
export alias scs = sudo systemctl status
export alias scsa = sudo systemctl start
export alias scso = sudo systemctl stop
export alias scu = systemctl --user
export alias scudn = systemctl --user disable --now
export alias scudr = systemctl --user daemon-reload
export alias scuen = systemctl --user enable --now
export alias scur = systemctl --user restart
export alias scus = systemctl --user status
export alias scusa = systemctl --user start
export alias scuso = systemctl --user stop
export alias se = sudoedit
export alias sf = sudo spf
export alias si = sudo -i
export alias sy = sudo yazi
export alias tf = terraform
export alias tree = broot -c :pt
export alias yq = yay -Q
export alias yr = yay -R --noconfirm
export alias yrs = yay -Rs --noconfirm
export alias ys = yay -Syu --noconfirm --disable-download-timeout

# LSD - Recursive alias needs lsd first.
export alias lsd = lsd --color=always --icon=always --group-dirs=first --git
export alias l = lsd -la
export alias lt = lsd -la --tree
export alias lz = lsd -laZ

#
# Alias-like commands.
#

# Search available packages with yay.
export def yss [...regexps: string] {
  yay --color=always -Ss ...$regexps
  | lines
  | chunks 2
  | each { { Package: $in.0, Description: ($in.1 | str trim) } }
  | sort-by { $in.Package | ansi strip }
}

# Search installed packages with yay.
export def yqs [...regexps: string] {
  yay --color=always -Qs ...$regexps
  | lines
  | chunks 2
  | each { { Package: $in.0, Description: ($in.1 | str trim) } }
  | sort-by { $in.Package | ansi strip }
}

# Opens vifm with TERM=kitty-direct.
export def --wrapped v [...args: string] {
  $env.TERM = "kitty-direct"
  ^vifm ...$args
}
