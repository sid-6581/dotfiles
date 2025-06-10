# Gets a list of paths starting with the path given, then every parent directory recursively.
export def walk-up [] : [
string -> list<string>
] {
  let components = $in | path expand | path split

  $components
  | enumerate
  | each {|it| $components | first ($it.index + 1) | path join }
  | reverse
}

# Finds a file in the given path or any parent directory.
#
# Returns the path to the first file that exists, or null if no file was found.
export def find-up [
  file: string # The file to find
] : [
string -> string
] {
  $in
  | walk-up
  | each { path join $file }
  | where { path exists }
  | get 0?
}
