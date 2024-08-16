alias dp := dot-pull
alias c := clean
alias dc := deepclean
alias i := install

noop:

dot-pull:
  cd ~/.dotfiles && git pull

clean:
  ~/.dotfiles/clean

deepclean:
  ~/.dotfiles/deepclean

install:
  cd ~/.dotfiles && git pull && ./install

update-pip:
  pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U

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
