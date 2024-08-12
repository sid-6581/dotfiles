# Gets the full paths of executables at any depth in the given directory.
export def main [
  directory: string # Path to directory with executables
] {
  cd $directory
  let files = glob "**/*"
  | each { ls -alD $in }
  | flatten
  | where type == file

  if $nu.os-info.name == "linux" {
    $files
    | where mode ends-with x
    | get name
  } else {
    $files
    | where name ends-with ".exe"
    | get name
  }
}
