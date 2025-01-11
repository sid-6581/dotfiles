export-env {
  $env.config.hooks.pre_prompt = [
    {
      condition: { which git | is-not-empty }

      code: {
        let git_root = ^git rev-parse --show-toplevel | complete | get stdout | str trim
        let precommit_config = [$git_root ".pre-commit-config.yaml"] | path join
        let precommit_hook = [$git_root ".git" "hooks" "pre-commit"] | path join

        if ($precommit_config | path exists) and not ($precommit_hook | path exists) {
          print $"(ansi red)WARNING: pre-commit configuration found, but pre-commit hook not installed(ansi reset)"
        }
      }
    },
  ]

  $env.config.hooks.env_change.PWD = [
    # Add directory to zoxide
    {
      condition: {|before, after| which zoxide | is-not-empty }
      code: {|before, after| ^zoxide add -- $after }
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
        print 'Using .nu overlay from ($file_path)'
        overlay use -r ($file_path) as .nu
        "
        | save -f ($nu.cache-dir | path join ".autoload-nu")

        true
      }

      code: $"
      source ($nu.cache-dir | path join .autoload-nu)
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
}
