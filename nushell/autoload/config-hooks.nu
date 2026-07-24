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

  const autoload_files = [".nu", ".nu.local"]

  def get-files-to-autoload [] {
    use ../scripts/path.nu

    $autoload_files
    | each {|it| $env.PWD | path find-up $it }
    | compact
  }

  def get-autoloaded-files [] {
    overlay list
    | get name
    | where $it in $autoload_files
    | each {|o| scope modules | where name == $o | get 0?.file }
    | compact
  }

  $env.config.hooks.env_change.PWD = [
    # Automatically hide autoloaded file overlays
    {
      code: {|before, after|
        let files_to_autoload = get-files-to-autoload
        let autoloaded_files = get-autoloaded-files

        if ($autoloaded_files | where $it not-in $files_to_autoload | is-empty) {
          return
        }

        # Unload all all autoloaded overlays by replacing the shell if we have
        # any autoloaded files that are no longer in a parent directory.
        # Hiding and reloading overlays/modules doesn't work properly in nushell yet.
        print $"Hiding overlays ($autoloaded_files | str join ', ')"
        exec nu -i
      }
    },

    # Autoload file overlays if found in path or parent directories.
    {
      code: {|before, after|
        let autoloaded_files = get-autoloaded-files
        let files_to_autoload = get-files-to-autoload | where $it not-in $autoloaded_files

        if ($files_to_autoload | is-empty) {
          return
        }

        let overlay_commands = $files_to_autoload
        | each {|f| $"overlay use -r ($f | to nuon) as ($f | path basename)" }
        | str join "\n"

        print $"Using overlays from ($files_to_autoload | str join ', ')"
        exec nu -e $overlay_commands
      }
    },

    # Add directory to zoxide
    {
      condition: {|before, after| which zoxide | is-not-empty }
      code: {|before, after| do -i { ^zoxide add $after } }
    },
  ]
}
