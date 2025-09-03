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
    # Automatically hide .nu if not found in path or parent directory.
    {
      condition: {|before, after|
        use ../scripts/path.nu

        if $before == null {
          return false
        }

        if not (overlay list | get name | any { $in | str ends-with ".nu" }) {
          return false
        }

        if not ($nu.cache-dir | path join .autounload-nu | path exists) {
          return false
        }

        true
      }

      code: "
      source ($nu.cache-dir | path join .autounload-nu)
      "
    },

    # Automatically use .nu/.nu.local if found in path or parent directory.
    {
      condition: {|before, after|
        use ../scripts/path.nu

        if $env.NU_EXEC? != null {
          $env.NU_EXEC = null
          return false
        }

        if (overlay list | get name | any { $in | str ends-with ".nu" }) {
          return false
        }

        let file_path = ($after | path find-up ".nu") | default ($after | path find-up ".nu.local")

        if $file_path == null {
          return false
        }

        mkdir $nu.cache-dir

        $"
        print 'Using .nu overlay from ($file_path)'
        $env.NU_EXEC = '1'
        do -i { exec nu -e 'overlay use -r ($file_path) as .nu' }
        "
        | save -f ($nu.cache-dir | path join .autoload-nu)

        $"
        print 'Hiding .nu overlay from ($file_path)'
        do -i { exec nu -i }
        "
        | save -f ($nu.cache-dir | path join .autounload-nu)

        true
      }

      code: $"
      source ($nu.cache-dir | path join .autoload-nu)
      cd $after
      "
    },

    # Add directory to zoxide
    {
      condition: {|before, after| which zoxide | is-not-empty }
      code: {|before, after| do -i { ^zoxide add $after } }
    },
  ]
}
