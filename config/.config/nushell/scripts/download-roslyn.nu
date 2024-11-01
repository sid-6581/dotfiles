use log.nu

# Downloads the Roslyn LSP language server and puts it in ~/.local/share/nvim-data/roslyn, where roslyn.nvim can find it.
def main [] {
  if $nu.os-info.name != "windows" {
    log error $"($env.CURRENT_FILE) must be run on Windows"
    return
  }

  const package_name = "Microsoft.CodeAnalysis.LanguageServer.win-x64"

  let latest_version = (
    http get "https://feeds.dev.azure.com/azure-public/vside/_apis/packaging/Feeds/vs-impl/packages?api-version=7.1"
    | get value
    | where name == $package_name
    | get versions.0
    | into record
  )

  let nvim_data_path = $env.HOME | path join .local share nvim-data

  if not ($nvim_data_path | path exists) {
    log error $"($nvim_data_path) does not exist, skipping install of Roslyn LSP"
    return
  }

  cd $nvim_data_path

  let unzipped_path = $nvim_data_path | path join $"roslyn-($latest_version.version)"

  if not ($unzipped_path | path exists) {
    let file_path = $nvim_data_path | path join $"roslyn-($latest_version.version).nupkg.zip"

    if not ($file_path | path exists) {
      log info $"Downloading Roslyn LSP version ($latest_version.version)"
      http get $"https://pkgs.dev.azure.com/azure-public/vside/_apis/packaging/feeds/vs-impl/nuget/packages/($package_name)/versions/($latest_version.version)/content?api-version=7.1-preview.1"
      | save $file_path
    }

    log info $"Extracting Roslyn LSP to ($unzipped_path)"
    mkdir $unzipped_path
    ^tar -xf $file_path -C $unzipped_path
    rm $file_path
  }

  let roslyn_path = $nvim_data_path | path join roslyn
  rm -rf $roslyn_path
  mkdir $roslyn_path

  ls -a ($unzipped_path | path join content LanguageServer win-x64)
  | get name
  | each { cp -r $in $roslyn_path }

  null
}
