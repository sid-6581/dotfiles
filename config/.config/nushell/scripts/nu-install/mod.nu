export use cargo.nu *
export use dnf.nu *
export use gh.nu *
export use git.nu *
export use link.nu *
export use scoop.nu *

# Extracts an archive's contents into the same directory, then deletes the archive.
# If the given file path is not to a known archive format, the file is left alone.
def extract [
  path: string # Absolute path to file to extract.
] {
  let directory = $path | path dirname

  if ($path ends-with tar.gz) {
    tar -xf $path -C $directory
    rm -rf $path
  } else if ($path ends-with gz) {
    gunzip $path
  } else if ($path ends-with zip) {
    if $nu.os-info.name == "linux" {
      unzip -qq $path -d $directory
    } else {
      tar -xf $path -C $directory
    }
    rm -rf $path
  }
}

# Gets the full paths of executables at any depth in the given directory.
def get-executables [directory: string] {
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

def "nu-install history path" [] {
  let directory = $"($env.HOME)/.local/share/nu-install"
  mkdir $directory
  [$directory history.json] | path join
}

def "nu-install history load" [] {
  let path = (nu-install history path)
  if ($path | path exists) {
    open (nu-install history path)
  } else {
    {}
  }
}

def "nu-install history save" [] {
  save -f (nu-install history path)
}

def "nu-install history update" [
  update: closure
] {
  nu-install history load | do $update | nu-install history save
}

def "nu-install history get" [
  path: any
] {
  nu-install history load | get -i ($path | into cell-path)
}

def "nu-install history upsert" [
  path: any
  value: any
] {
  nu-install history update { upsert ($path | into cell-path) $value }
}

def "nu-install history remove" [
  path: any
] {
  nu-install history update { reject ($path | into cell-path) }
}
