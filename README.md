# Installation

These dotfiles are designed to be installed in a WSL2 instance of Fedora Remix.

If there is already an instance of Fedora Remix installed, it's recommended to
uninstall and reinstall the instance by running the following commands in
PowerShell, then reinstalling Fedora Remix:

```ps1
wsl --shutdown
wsl --unregister fedoraremix
```

Inside a fresh Fedora Remix instance, run the following commands one by one:

```sh
sudo dnf install git -y
git clone https://github.com/sid-6581/dotfiles ~/.dotfiles
~/.dotfiles/install
```
