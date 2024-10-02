# Returns a list of paths starting with the path given, then every parent directory recursively.
export def walk-parents [
  path: string # The path to find parent directories of
] {
  let components = $path | path expand | path split

  $components
  | enumerate
  | each {|it| $components | first ($it.index + 1) | path join }
  | reverse
}

# Finds a file in the given path or any parent directory.
export def find-in-parents [
  path: string # The path to find file in
  file: string # The file to find
] {
  walk-parents $path
  | each { path join $file }
  | filter { path exists }
  | get 0?
}
