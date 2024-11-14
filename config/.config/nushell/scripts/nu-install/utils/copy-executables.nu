use ./get-executables.nu

# Copies executables from one directory to another. This will rename the
# existing executable before copying the new file in its place, since running
# executables can't be replaced.
export def main [
  source: any          # Either a path to a source directory or a list of paths to executable files
  destination: string  # Path to destination directory
] {
  let source_type = $source | describe
  let executables = if $source_type == "string" {
    let executables = get-executables $source
    if ($executables | length) == 0 {
      error make { msg: $"No executables found in ($source)" }
    }
    $executables
  } else if $source_type == "list<string>" {
    $source
  } else {
    error make { msg: $"Invalid type for source: ($source)" }
  }

  # Copy executables to the destination.
  for $executable in $executables {
    let file_name = $executable | path basename
    let destination_file_path = $destination | path join $file_name

    if ($destination_file_path | path exists) {
      mv -f $destination_file_path $"($destination_file_path).bak"
    }

    cp -f $executable $destination_file_path

    # Launch in a separate nushell instance so we can properly suppress the error.
    # The built-in rm currently doesn't let us suppress it.
    ^nu -c $"rm -f '($destination_file_path)' '($destination_file_path).bak'"
  }
}
