# Show a list of broken symlinks in the current directory and all child directories, and delete the ones the user selects.
export def delete-broken-symlinks [] {
  let files = ls -alD **/*
  | where type == symlink
  | where not ($it.target | path exists)
  | get name

  if ($files | is-empty) {
    return
  }

  $files
  | input list -m
  | each { ^rm -rf $in }

  return
}
