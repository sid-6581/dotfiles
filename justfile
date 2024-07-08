set positional-arguments

@default:
    just --list

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
