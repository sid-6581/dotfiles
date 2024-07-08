# Paths

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $"($env.HOME)/.cargo/bin"
  | prepend $"($env.HOME)/.local/bin"
  | append $"($env.HOME)/.local/share/pnpm"
  | append $"($env.HOME)/.local/share/bob/nvim-bin"
  | append $"($env.HOME)/go/bin"
  | append "/mnt/c/Program Files/Oracle/VirtualBox"
  | uniq
  | str join (char esep)
)

let autoload_source = ls $"($nu.default-config-dir)/autoload-source" | each { $"source ($in.name)" }
let autoload_modules = ls $"($nu.default-config-dir)/autoload-modules" | each { $"use ($in.name) *" }
$autoload_source ++ $autoload_modules | save -f $"($nu.default-config-dir)/autoload.nu"
