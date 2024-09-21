# Set user environment variables in the registry, and also load them into the current scope.
export def --env set-user-env [
  environment: record # Environment variables to set.
] {
  let current_environment = registry query --hkcu Environment | group-by name

  # Set the environment variables that are different from what's currently in the registry.
  # We don't want to set them all regardless, because modifying the registry is slow.
  $environment
  | transpose key value
  | filter {|it| ($current_environment | get -i ([$it.key value 0] | into cell-path)) != $it.value }
  | each {|it|
    log info $"Setting environment variable ($it.key) to ($it.value)"
    ^setx $it.key $it.value
  }

  # Load environment in this scope so it's immediately available.
  load-env ($environment | reject Path)
}
