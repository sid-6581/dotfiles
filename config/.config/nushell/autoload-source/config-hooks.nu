$env.config.hooks.pre_prompt = [{
  if not (which direnv | is-empty) {
    direnv export json | from json | default {} | load-env
  }
  if $env.PROMPT_RENDERED? == true {
    print ""
  }
}]

$env.config.hooks.pre_execution = [{
  print ""
  $env.PROMPT_RENDERED = true
}]
