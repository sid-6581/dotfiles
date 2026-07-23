export-env {
  $env.config.hooks.pre_prompt = [
    {
      condition: { (which git | is-not-empty) and (".git" | path type) == "dir" }

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
    # Automatically hide .nu/.nu.local
    {
      condition: {|before, after|
        use ../scripts/path.nu

        if $before == null {
          return false
        }

        if not (overlay list | get name | any { $in | str starts-with ".nu" }) {
          return false
        }

        let autounload_file = $nu.cache-dir | path join $".autounload-nu-($nu.pid)"

        if not ($autounload_file | path exists) {
          return false
        }

        true
      }

      code: $"
      source (($nu.cache-dir | path join ('.autounload-nu-' + ($nu.pid | into string))) | to nuon)
      "
    },

    # Automatically use .nu/.nu.local if found in path or parent directories.
    {
      condition: {|before, after|
        use ../scripts/path.nu

        if $env.NU_EXEC? != null {
          $env.NU_EXEC = null
          return false
        }

        if (overlay list | get name | any { $in | str starts-with ".nu" }) {
          return false
        }

        let file_paths = [
          ($after | path find-up ".nu")
          ($after | path find-up ".nu.local")
        ] | compact

        if ($file_paths | is-empty) {
          return false
        }

        mkdir $nu.cache-dir

        let autoload_file = $nu.cache-dir | path join $".autoload-nu-($nu.pid)"
        let autounload_file = $nu.cache-dir | path join $".autounload-nu-($nu.pid)"

        let overlay_commands = $file_paths
        | each {|file_path| $"overlay use -r ($file_path | to nuon) as ($file_path | path basename)" }
        | str join "\n"

        $"
        print 'Using overlays from ($file_paths | str join ', ')'
        $env.NU_EXEC = '1'
        rm -f ($autoload_file | to nuon)
        do -i { exec nu -e ($overlay_commands | to nuon) }
        "
        | save -f $autoload_file

        $"
        print 'Hiding overlays from ($file_paths | str join ', ')'
        rm -f ($autounload_file | to nuon)
        do -i { exec nu -i }
        "
        | save -f $autounload_file

        true
      }

      code: $"
      source (($nu.cache-dir | path join ('.autoload-nu-' + ($nu.pid | into string))) | to nuon)
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
