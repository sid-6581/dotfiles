export def "nu-install history path" [] {
  let directory = $"($env.HOME)/.local/share/nu-install"
  mkdir $directory
  [$directory history.yaml] | path join
}

export def "nu-install history load" [] {
  let path = (nu-install history path)
  if ($path | path exists) {
    open (nu-install history path)
  } else {
    {}
  }
}

export def "nu-install history save" [] {
  to yaml
  | save -f (nu-install history path)
}

export def "nu-install history update" [
  update: closure
] {
  nu-install history load | do $update | nu-install history save
}

export def "nu-install history get" [
  path: any
] {
  nu-install history load | get -i ($path | into cell-path)
}

export def "nu-install history upsert" [
  path: any
  value: any
] {
  nu-install history update { upsert ($path | into cell-path) $value }
}

export def "nu-install history remove" [
  path: any
] {
  nu-install history update { reject ($path | into cell-path) }
}
