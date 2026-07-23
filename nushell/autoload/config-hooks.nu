def auto-overlay-state [directory] {
  use ../scripts/path.nu

  let overlays = overlay list
  let modules = scope modules
  let base_active = $overlays | any {|item| $item.name == ".nu" and $item.active }
  let local_active = $overlays | any {|item| $item.name == ".nu.local" and $item.active }

  {
    current: {
      base: (if $base_active { $modules | where name == ".nu" | get file.0? })
      local: (if $local_active { $modules | where name == ".nu.local" | get file.0? })
    }
    next: {
      base: ($directory | path find-up ".nu")
      local: ($directory | path find-up ".nu.local")
    }
  }
}

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
    # Automatically use .nu and .nu.local from the current path or a parent directory.
    {
      condition: {|_, after|
        let state = auto-overlay-state $after
        (
          ($state.current.local != null and $state.current.local != $state.next.local) or
          ($state.current.base != null and $state.current.base != $state.next.base)
        )
      }

      code: '
        let state = auto-overlay-state $env.PWD
        if $state.current.local != null and $state.current.local != $state.next.local {
          print $"Hiding .nu.local overlay from ($state.current.local)"
          overlay hide --keep-env [PWD] .nu.local
        }
        if $state.current.base != null and $state.current.base != $state.next.base {
          print $"Hiding .nu overlay from ($state.current.base)"
          overlay hide --keep-env [PWD] .nu
        }
      '
    },
    {
      condition: {|_, after|
        if $env.__NU_AUTO_OVERLAY_EXEC? != null {
          hide-env __NU_AUTO_OVERLAY_EXEC
          return false
        }

        let state = auto-overlay-state $after
        $state.current != $state.next and ($state.next.base != null or $state.next.local != null)
      }

      code: {|_, after|
        let state = auto-overlay-state $after
        let commands = [
          (if $state.next.base != null {
            print $"Using .nu overlay from ($state.next.base)"
            $"overlay use -r ($state.next.base | to nuon) as .nu"
          })
          (if $state.next.local != null {
            print $"Using .nu.local overlay from ($state.next.local)"
            $"overlay use -r ($state.next.local | to nuon) as .nu.local"
          })
        ] | compact

        $env.__NU_AUTO_OVERLAY_EXEC = "1"
        exec $nu.current-exe -e ($commands | str join "\n")
      }
    },

    # Add directory to zoxide
    {
      condition: {|before, after| which zoxide | is-not-empty }
      code: {|before, after| do -i { ^zoxide add $after } }
    },
  ]
}
