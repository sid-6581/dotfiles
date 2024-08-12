# Extracts an archive's contents into the same directory, then deletes the archive.
# If the given file path is not a known archive format, the file is left alone.
# Currently handles .tar.gz, .gz, and .zip.
export def main [
  path: string # Absolute path to file to extract.
] {
  let directory = $path | path dirname

  if ($path ends-with tar.gz) {
    ^tar -xf $path -C $directory
    rm -rf $path
  } else if ($path ends-with gz) {
    ^gunzip $path
  } else if ($path ends-with zip) {
    if $nu.os-info.name == "linux" {
      ^unzip -qq $path -d $directory
    } else {
      ^tar -xf $path -C $directory
    }
    rm -rf $path
  }
}
