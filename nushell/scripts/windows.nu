use log.nu

# Set user environment variables in the registry, and also load them into the current scope.
export def --env set-user-env [
  environment: record # Environment variables to set.
] {
  $env.LOG_CATEGORY = "windows.nu set-user-env"

  let current_environment = registry query --hkcu Environment | group-by name

  # Set the environment variables that are different from what's currently in the registry.
  # We don't want to set them all regardless, because modifying the registry is slow.
  $environment
  | transpose key value
  | each {|it|
    let current_value = $current_environment | get -i ([$it.key value 0] | into cell-path)
    if $it.value != $current_value {
      log info $"Setting environment variable ($it.key) to ($it.value) \(Current value: ($current_value)\)"
      ^setx $it.key $it.value
    }
  }

  # Load environment in this scope so it's immediately available.
  load-env ($environment | reject Path)
}

# Add or overwrite a registry value.
export def "registry add" [
  key_name: string   # The registry key name
  value_name: string # The registry value name
  value: any         # The value to add
] {
  $env.LOG_CATEGORY = "windows.nu registry add"

  let type = match ($value | describe) { "string" => "REG_SZ", "int" => "REG_DWORD" }
  let query_value = ^reg query $key_name /v $value_name | complete

  let old_value = if $query_value.exit_code == 0 {
    let value_string = $query_value.stdout | str trim | parse --regex '.*REG_\w+\s+(?<value>.+)' | get value.0
    match $type { "REG_SZ" => $value_string, "REG_DWORD" => { $value_string | into int } }
  } else {
    null
  }

  if $old_value != $value {
    log info $"Setting environment variable ($key_name)\\($value_name) to ($value) \(Current value: ($old_value)\)"
  }

  let result = ^reg add $key_name /f /v $value_name /t $type /d $value | complete
  if $result.exit_code != 0 {
    log error $"Error setting environment variable ($key_name)\\($value_name): ($result.stderr | str trim)"
  }
}
