export def "history path" [] {
  let directory = $"($env.HOME)/.local/share/nu-install"
  mkdir $directory
  [$directory history.yaml] | path join
}

export def "history load" [] {
  let path = (history path)
  if ($path | path exists) {
    open (history path)
  } else {
    {}
  }
}

export def "history save" [] {
  to yaml
  | save -f (history path)
}

export def "history update" [
  update: closure
] {
  history load | do $update | history save
}

export def "history get" [
  path: any
] {
  history load | get -o ($path | into cell-path)
}

export def "history upsert" [
  path: any
  value: any
] {
  history update { upsert ($path | into cell-path) $value }
}

export def "history remove" [
  path: any
] {
  history update { reject ($path | into cell-path) }
}
