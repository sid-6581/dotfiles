$env.config.hooks.pre_prompt = [{
  if (which direnv | is-not-empty) {
    direnv export json | from json | default {} | load-env
  }

  let git_root = git rev-parse --show-toplevel | complete | get stdout | str trim
  let precommit_config = [$git_root ".pre-commit-config.yaml"] | path join
  let precommit_hook = [$git_root ".git" "hooks" "pre-commit"] | path join

  if ($precommit_config | path exists) and not ($precommit_hook | path exists) {
    print $"(ansi red)WARNING: pre-commit configuration found, but pre-commit hook not installed(ansi reset)\n"
  }
}]

$env.config.hooks.env_change.PWD = [
  {
    condition: {|before, after| which zoxide | is-not-empty }
    code: {|before, after| zoxide add -- $after }
  }
]
