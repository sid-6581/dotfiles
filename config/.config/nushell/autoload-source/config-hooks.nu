$env.config.hooks.pre_prompt = [
  {
    let git_root = git rev-parse --show-toplevel | complete | get stdout | str trim
    let precommit_config = [$git_root ".pre-commit-config.yaml"] | path join
    let precommit_hook = [$git_root ".git" "hooks" "pre-commit"] | path join

    if ($precommit_config | path exists) and not ($precommit_hook | path exists) {
      print $"(ansi red)WARNING: pre-commit configuration found, but pre-commit hook not installed(ansi reset)\n"
    }
  },
]

$env.config.hooks.pre_execution = [
  {
    $env.PROMPT_RENDERED = true
    print ""
  }
]

$env.config.hooks.env_change.PWD = [
  # Add directory to zoxide
  {
    condition: {|before, after| which zoxide | is-not-empty }
    code: {|before, after| zoxide add -- $after }
  },

  # Automatically use .nu if found in path or parent directory.
  {
    condition: {|before, after|
      use ../scripts/path.nu

      if (".nu" in (overlay list)) {
        return false
      }

      let file_path = $after | path find-up ".nu"

      if $file_path == null {
        return false
      }

      mkdir $nu.cache-dir

      $"
      export-env { use ($file_path) }
      export use ($file_path) *
      "
      | save -f ($nu.cache-dir | path join ".autoload-nu")

      true
    }
    code: "
    print 'Using .nu overlay'
    overlay use -r ($nu.cache-dir | path join .autoload-nu) as .nu
    cd $after
    "
  },

  # Automatically hide .nu if not found in path or parent directory.
  {
    condition: {|before, after|
      use ../scripts/path.nu
      (".nu" in (overlay list)) and ($after | path find-up ".nu") == null
    }
    code: "
    print 'Hiding .nu overlay'
    overlay hide .nu --keep-env [PWD]
    "
  },
]
