set positional-arguments

alias i := install

@default:
    just --list

install:
  cd ~/.dotfiles && git pull && ./install

# Install pre-commit hooks
install-precommit:
    pip3 install -q pre-commit
    pre-commit install

# Run pre-commit on all files
run-precommit:
    pre-commit run --all-files

# Update pre-commit hooks
update-precommit:
    pre-commit autoupdate
