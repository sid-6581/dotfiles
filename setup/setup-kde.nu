use ../config/.config/nushell/scripts/log.nu

const category = "setup-kde"

def values [] {
  return [
    ["breezerc", "Common", "OutlineIntensity", "OutlineOff"],
    ["breezerc", "Style", "MnemonicsMode", "MN_ALWAYS"],
    ["breezerc", "Windeco", "DrawBackgroundGradient", "true"],
    ["kaccessrc", "Bell", "SystemBell", "false"],
    ["kcminputrc", "Keyboard", "RepeatDelay", "200"],
    ["kcminputrc", "Mouse", "X11LibInputXAccelProfileFlat", "true"],
    ["kcminputrc", "Mouse", "XLbInptScrollOnButtonDown", "true"],
    ["kdeglobals", "General", "XftAntialias", "true"],
    ["kdeglobals", "General", "XftHintStyle", "hintfull"],
    ["kdeglobals", "General", "XftSubPixel", "rgb"],
    ["kdeglobals", "General", "fixed", "JetBrainsMonoNL Nerd Font,9.5,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"],
    ["kdeglobals", "KDE", "AnimationDurationFactor", "0"],
    ["kdeglobals", "KDE", "LookAndFeelPackage", "org.kde.breezedark.desktop"],
    ["kdeglobals", "KFileDialog Settings", "Show hidden files", "true"],
    ["kdeglobals", "KFileDialog Settings", "View Style", "DetailTree"],
    ["kdeglobals", "Sounds", "Enable", "false"],
    ["klaunchrc", "BusyCursorSettings", "Bouncing", "false"],
    ["klaunchrc", "FeedbackStyle", "BusyCursor", "false"],
    ["kwinrc", "EdgeBarrier", "CornerBarrier", "false"],
    ["kwinrc", "Script-kzones", "layoutsJson", (
      [
        {
          "name": "Priority Grid",
          "padding": 5,
          "zones": [
            {
              "x": 0,
              "y": 0,
              "height": 100,
              "width": 25
            },
            {
              "x": 25,
              "y": 0,
              "height": 100,
              "width": 50,
              "applications": [
                "org.wezfurlong.wezterm"
              ]
            },
            {
              "x": 75,
              "y": 0,
              "height": 100,
              "width": 25
            }
          ]
        },
        {
          "name": "Quadrant Grid",
          "zones": [
            {
              "x": 0,
              "y": 0,
              "height": 50,
              "width": 50
            },
            {
              "x": 0,
              "y": 50,
              "height": 50,
              "width": 50
            },
            {
              "x": 50,
              "y": 50,
              "height": 50,
              "width": 50
            },
            {
              "x": 50,
              "y": 0,
              "height": 50,
              "width": 50
            }
          ]
        }
      ]
      | to json
    )],
    ["kwinrc", "Script-kzones", "zoneOverlayHighlightTarget", "1"],
    ["kwinrc", "Script-kzones", "zoneSelectorTriggerDistance", "2"],
    ["kwinrc", "TabBox", "HighlightWindows", "false"],
    ["kwinrc", "Effect-overview", "BorderActivate", "9"],
    ["kwinrc", "Windows", "ElectricBorderMaximize", "false"],
    ["kwinrc", "Windows", "ElectricBorderTiling", "false"],
    ["plasmaparc", "General", "AudioFeedback", "false"],
  ]
}

export def settings [] {
  if (which kwriteconfig6 | is-empty) {
    log warning -c $category "kwriteconfig6 not found"
    return
  }

  if (which kreadconfig6 | is-empty) {
    log warning -c $category "kreadconfig6 not found"
    return
  }

  for $value in (values) {
    let existing_value = ^kreadconfig6 --file $value.0 --group $value.1 --key $value.2

    if $existing_value != $value.3 {
      log info -c $category $"Setting ($value.0)/($value.1)/($value.2) to ($value.3)"
      ^kwriteconfig6 --file $value.0 --group $value.1 --key $value.2 $value.3
    }
  }
}
