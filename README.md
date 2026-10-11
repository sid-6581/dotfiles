# Installation

These dotfiles are designed to be installed in Arch, or Arch running in WSL2.
paru should be set up before starting.

To install:

```sh
git clone https://github.com/sid-6581/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install
```

# ChatGPT Community

Run `setup codex install` in Nushell to clone or update
`~/Code/Personal/codex-desktop-linux` on `main` with `git pull --ff-only`, then
build and install its native package with the features saved in
[`linux-features.json`](nushell/scripts/setup/files/codex/linux-features.json).
Existing per-feature settings are preserved. Builds use a disk-backed cache
for temporary files and eight build threads.

Load the setup module into a Nushell session, then run:

```nu
use ~/.dotfiles/nushell/scripts/setup
setup codex install
```
