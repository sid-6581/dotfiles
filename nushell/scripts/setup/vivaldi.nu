# Sets up vivaldi.
export def main [] {
  let preferences_path = "~/.config/vivaldi/Default/Preferences" | path expand
  const new_preferences_path = path self files/vivaldi/Preferences.json

  let preferences = open --raw $preferences_path | from json
  let new_preferences = open $new_preferences_path
  let new_preferences = $preferences | merge deep $new_preferences

  $preferences | to json | save -f $"($preferences_path).bak"
  $new_preferences | to json | save -f $preferences_path
}
