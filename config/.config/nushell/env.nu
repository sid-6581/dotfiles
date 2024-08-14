$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.XDG_DATA_HOME = $"($env.HOME)/.local/share"
$env.XDG_STATE_HOME = $"($env.HOME)/.local/state"
$env.HOME = if $nu.os-info.name == "linux" { $env.HOME } else { $env.HOME? | default $env.USERPROFILE }

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $"($env.HOME)/.cargo/bin"
  | prepend $"($env.HOME)/.local/bin"
  | append $"($env.HOME)/.local/share/pnpm"
  | append $"($env.HOME)/.local/share/bob/nvim-bin"
  | append $"($env.HOME)/go/bin"
  | filter {|p| $p !~ "(?i)^/mnt/./" } # Strip Windows WSL paths
  | append (if $nu.os-info.name == "linux" { "/mnt/c/Program Files/Oracle/VirtualBox" } else { null })
  | uniq
  | str join (char esep)
)

# Generate autoload.nu file that will be sourced in config.nu
let autoload_path = $"($nu.default-config-dir)/autoload.nu"

let autoload_contents = (
  ((do -i { ls $"($nu.default-config-dir)/autoload-source" | sort | each { $"source ($in.name)" } }) | default [])
  ++
  ((do -i { ls $"($nu.default-config-dir)/autoload-modules" | sort | each { $"use ($in.name) *" } }) | default [])
) | str join "\n"

if $autoload_contents != "" and (do -i { open -r $autoload_path }) != $autoload_contents {
  $autoload_contents | save -f $autoload_path
}
