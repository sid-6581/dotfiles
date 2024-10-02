use ../scripts/path.nu

$env.config.hooks.pre_prompt = [{
  if $env.PROMPT_RENDERED? == true {
    print ""
  }

  let git_root = git rev-parse --show-toplevel | complete | get stdout | str trim
  let precommit_config = [$git_root ".pre-commit-config.yaml"] | path join
  let precommit_hook = [$git_root ".git" "hooks" "pre-commit"] | path join

  if ($precommit_config | path exists) and not ($precommit_hook | path exists) {
    print $"(ansi red)WARNING: pre-commit configuration found, but pre-commit hook not installed(ansi reset)\n"
  }
}]

$env.config.hooks.pre_execution = [
  {
    print ""
    $env.PROMPT_RENDERED = true
  }
]

$env.config.hooks.env_change.PWD = [
  # # Load direnv files
  # {
  #   condition: {|before, after| which direnv | is-not-empty }
  #   code: {|before, after| direnv export json | from json | default {} | load-env }
  # },

  # Add directory to zoxide
  {
    condition: {|before, after| which zoxide | is-not-empty }
    code: {|before, after| zoxide add -- $after }
  },

  # Automatically load .nu if found in path or parent directory.
  {
    condition: {|before, after|
      if (".nu" in (overlay list)) {
        return false
      }

      let file_path = (path find-in-parents $after ".nu")
      if $file_path == null {
        return false
      }

      mkdir $nu.cache-dir
      $"
      export-env {
      export use ($file_path) *
      }
      " | save -f ($nu.cache-dir | path join ".autoload-nu")
      true
    }
    code:
    $"
    overlay use -r ($nu.cache-dir)/.autoload-nu as .nu
    cd \($after\)
    "
  },

  # Automatically unload .nu if not found in path or parent directory.
  {
    condition: {|before, after| (".nu" in (overlay list)) and (path find-in-parents $after ".nu") == null}
    code:
    "
    overlay hide .nu --keep-env [PWD]
    "
  }
]
