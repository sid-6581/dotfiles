use log.nu
use state.nu
use utils/extract.nu
use utils/get-executables.nu
use utils/copy-executables.nu

const category = "nu-install hashicorp"

# Downloads a release from the HashiCorp official repo, extracts all binaries,
# and copies them to the target directory.
#
# Each product record should have the following required or optional fields:
#
# name        The name of the application to download
# version?    The version to download, defaults to "latest"
# arch?       The desired architecture, defaults to "amd64"
# os?         The desired OS, defaults to "linux"
export def main [
  products: list<any>         # The products to install, either a list of product names or a list of product records
  --destination (-d): string  # The destination directory (default $HOME/.local/bin)
] {
  let destination = $destination | default $"($env.HOME)/.local/bin/"

  let products = if ($products | describe) == "list<string>" {
    $products | each { { name: $in } }
  } else {
    $products
  }

  for $product in $products {
    let version = $product.version? | default "latest"
    let arch = $product.arch? | default "amd64"
    let os = $product.os? | default "linux"

    let details = http get $"https://api.releases.hashicorp.com/v1/releases/($product.name)/($version)"
    let version = $details.version
    let url = $details.builds | where arch == $arch and os == $os | get 0.url

    # If we've already installed a release with this version, skip the rest.
    let history_version = state history get ["hashicorp" $product.name "version"]
    if $history_version == $version {
      continue
    }

    log info -c $category $"Downloading executables for ($product.name) (($version))"

    let temp_directory = mktemp -d

    try {
      let temp_file_path = $temp_directory | path join ($url | path basename)
      http get $url | save $temp_file_path

      extract $temp_file_path
      copy-executables $temp_directory $destination

      state history upsert ["hashicorp" $product.name] {
        version: $version
        executables: (get-executables $temp_directory | each { path basename })
      }
    } catch {|e|
      log error -c $category $"Error downloading release from ($url): ($e.msg)"
    }

    rm -rf $temp_directory
  }
}

# Deletes executables installed from HashiCorp.
export def uninstall [
  product: string             # The product to uninstall
  --destination (-d): string  # The destination directory (default $HOME/.local/bin)
] {
  let destination = $destination | default ($env.HOME | path join .local bin)
  let executables = state history get ["hashicorp" $product "executables"]

  if ($executables | is-empty) {
    return
  }

  log info -c $category $"Deleting executables downloaded for ($product)"

  $executables | each { rm -f ([$destination $in] | path join) }

  state history remove ["hashicorp" $product]
}
