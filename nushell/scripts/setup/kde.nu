# Updates KDE settings from files.
export def files [
  dir: string # The directory containing the settings files.
] {
  use ../log.nu
  $env.LOG_CATEGORY = "setup kde files"

  if (which kwriteconfig6 | is-empty) {
    log warning "kwriteconfig6 not found"
    return
  }

  if (which kreadconfig6 | is-empty) {
    log warning "kreadconfig6 not found"
    return
  }

  for $file in (ls -al $dir | get name) {
    let filename = $file | path basename
    let lines = open --raw $file | lines | compact -e
    let sections = (
      $lines
      | chunk-by { $in starts-with "[" }
      | chunks 2
      | each { { $in.0.0: $in.1 } }
      | into record
    )

    for $section in ($sections | transpose name values) {
      let groups = (
        $section.name
        | split row -r r#'\[|\]'#
        | compact -e
        | each { ["--group", $in] }
        | flatten
      )

      for $value in $section.values {
        let setting = $value | parse "{name}={value}" | into record
        let existing_value = ^kreadconfig6 --file $filename ...$groups --key $setting.name

        if $existing_value != $setting.value {
          log info $"Setting ($filename) ($section.name) ($setting.name) to ($setting.value)"
          ^kwriteconfig6 --file $filename ...$groups --key $setting.name $setting.value
        }
      }
    }
  }
}
