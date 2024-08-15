$env.config.hooks.pre_prompt = [{
  if not (which direnv | is-empty) {
    direnv export json | from json | default {} | load-env
  }

  if (".pre-commit-config.yaml" | path exists) and not (".git/hooks/pre-commit" | path exists) {
    print $"(ansi red)WARNING: pre-commit configuration found, but pre-commit hook not installed(ansi reset)"
  }

  if $env.PROMPT_RENDERED? == true {
    print ""
  }
}]

$env.config.hooks.pre_execution = [{
  print ""
  $env.PROMPT_RENDERED = true
}]
