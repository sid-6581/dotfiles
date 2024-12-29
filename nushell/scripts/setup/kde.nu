use ../log.nu

def values [] {
  return [
    ["baloofilerc", "Basic Settings", "Indexing-Enabled", "false"],
    ["breezerc", "Common", "OutlineIntensity", "OutlineOff"],
    ["breezerc", "Style", "MnemonicsMode", "MN_ALWAYS"],
    ["breezerc", "Windeco", "DrawBackgroundGradient", "true"],
    ["kaccessrc", "Bell", "SystemBell", "false"],
    ["kactivitymanagerd-pluginsrc", "Plugin-org.kde.ActivityManager.Resources.Scoring", "what-to-remember", "2"],
    ["kcminputrc", "Keyboard", "RepeatDelay", "200"],
    ["kcminputrc", "Keyboard", "RepeatRate", "35"],
    ["kcminputrc", "Mouse", "X11LibInputXAccelProfileFlat", "true"],
    ["kcminputrc", "Mouse", "XLbInptScrollOnButtonDown", "true"],
    ["kdeglobals", "General", "XftAntialias", "true"],
    ["kdeglobals", "General", "XftHintStyle", "hintfull"],
    ["kdeglobals", "General", "XftSubPixel", "rgb"],
    ["kdeglobals", "General", "fixed", "JetBrainsMono Nerd Font,9.5,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"],
    ["kdeglobals", "KDE", "AnimationDurationFactor", "0"],
    ["kdeglobals", "KDE", "LookAndFeelPackage", "org.kde.breezedark.desktop"],
    ["kdeglobals", "KFileDialog Settings", "Show hidden files", "true"],
    ["kdeglobals", "KFileDialog Settings", "View Style", "DetailTree"],
    ["kdeglobals", "Sounds", "Enable", "false"],
    ["kglobalshortcutsrc", "KDE Keyboard Layout Switcher", "Switch to Last-Used Keyboard Layout", "none,Meta+Alt+L,Switch to Last-Used Keyboard Layout"],
    ["kglobalshortcutsrc", "KDE Keyboard Layout Switcher", "Switch to Next Keyboard Layout", "none,Meta+Alt+K,Switch to Next Keyboard Layout"],
    ["kglobalshortcutsrc", "ksmserver", "Lock Session", "Meta+Shift+L\tScreensaver,Meta+L\tScreensaver,Lock Session"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 1", "none,none,KZones: Activate layout 1"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 2", "none,none,KZones: Activate layout 2"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 3", "none,none,KZones: Activate layout 3"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 4", "none,none,KZones: Activate layout 4"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 5", "none,none,KZones: Activate layout 5"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 6", "none,none,KZones: Activate layout 6"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 7", "none,none,KZones: Activate layout 7"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 8", "none,none,KZones: Activate layout 8"],
    ["kglobalshortcutsrc", "kwin", "KZones: Activate layout 9", "none,none,KZones: Activate layout 9"],
    ["kglobalshortcutsrc", "kwin", "KZones: Cycle layouts", "none,none,KZones: Cycle layouts"],
    ["kglobalshortcutsrc", "kwin", "KZones: Cycle layouts (reversed)", "none,none,KZones: Cycle layouts (reversed)"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window down", "none,none,KZones: Move active window down"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window left", "none,none,KZones: Move active window left"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window right", "none,none,KZones: Move active window right"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to next zone", "Meta+Right,none,KZones: Move active window to next zone"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to previous zone", "Meta+Left,none,KZones: Move active window to previous zone"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 1", "none,none,KZones: Move active window to zone 1"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 2", "none,none,KZones: Move active window to zone 2"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 3", "none,none,KZones: Move active window to zone 3"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 4", "none,none,KZones: Move active window to zone 4"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 5", "none,none,KZones: Move active window to zone 5"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 6", "none,none,KZones: Move active window to zone 6"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 7", "none,none,KZones: Move active window to zone 7"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 8", "none,none,KZones: Move active window to zone 8"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window to zone 9", "none,none,KZones: Move active window to zone 9"],
    ["kglobalshortcutsrc", "kwin", "KZones: Move active window up", "none,none,KZones: Move active window up"],
    ["kglobalshortcutsrc", "kwin", "KZones: Snap active window", "none,none,KZones: Snap active window"],
    ["kglobalshortcutsrc", "kwin", "KZones: Snap all windows", "none,none,KZones: Snap all windows"],
    ["kglobalshortcutsrc", "kwin", "KZones: Switch to next window in current zone", "Meta+J,none,KZones: Switch to next window in current zone"],
    ["kglobalshortcutsrc", "kwin", "KZones: Switch to previous window in current zone", "Meta+K,none,KZones: Switch to previous window in current zone"],
    ["kglobalshortcutsrc", "kwin", "KZones: Toggle zone overlay", "none,none,KZones: Toggle zone overlay"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Bottom", "none,Meta+Down,Quick Tile Window to the Bottom"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Bottom Left", "none,,Quick Tile Window to the Bottom Left"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Bottom Right", "none,,Quick Tile Window to the Bottom Right"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Left", "none,Meta+Left,Quick Tile Window to the Left"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Right", "none,Meta+Right,Quick Tile Window to the Right"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Top", "none,Meta+Up,Quick Tile Window to the Top"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Top Left", "none,,Quick Tile Window to the Top Left"],
    ["kglobalshortcutsrc", "kwin", "Window Quick Tile Top Right", "none,,Quick Tile Window to the Top Right"],
    ["kglobalshortcutsrc", "kwin", "Switch Window Down", "Meta+Alt+Down\tMeta+Alt+J,Meta+Alt+Down,Switch to Window Below"],
    ["kglobalshortcutsrc", "kwin", "Switch Window Left", "Meta+Alt+Left\tMeta+H,Meta+Alt+Left,Switch to Window to the Left"],
    ["kglobalshortcutsrc", "kwin", "Switch Window Right", "Meta+Alt+Right\tMeta+L,Meta+Alt+Right,Switch to Window to the Right"],
    ["kglobalshortcutsrc", "kwin", "Switch Window Up", "Meta+Alt+Up,Meta+Alt+Up,Switch to Window Above"],
    ["klaunchrc", "BusyCursorSettings", "Bouncing", "false"],
    ["klaunchrc", "FeedbackStyle", "BusyCursor", "false"],
    ["krunnerrc", "Plugins", "baloosearchEnabled", "false"],
    ["krunnerrc", "Plugins", "browserhistoryEnabled", "false"],
    ["krunnerrc", "Plugins", "browsertabsEnabled", "false"],
    ["krunnerrc", "Plugins", "krunner_appstreamEnabled", "false"],
    ["krunnerrc", "Plugins", "krunner_bookmarksrunnerEnabled", "false"],
    ["krunnerrc", "Plugins", "krunner_recentdocumentsEnabled", "false"],
    ["krunnerrc", "Plugins", "krunner_webshortcutsEnabled", "false"],
    ["ksplashrc", "KSplash", "Engine", "none"],
    ["ksplashrc", "KSplash", "Theme", "none"],
    ["kwinrc", "EdgeBarrier", "CornerBarrier", "false"],
    ["kwinrc", "Script-kzones", "layoutsJson", (
      [
        {
          "name": "Priority Grid",
          "padding": 4,
          "zones": [
            {
              "x": 0,
              "y": 0,
              "height": 100,
              "width": 25,
              "applications": [
                "discord",
              ]
            },
            {
              "x": 25,
              "y": 0,
              "height": 100,
              "width": 50,
              "applications": [
                "org.wezfurlong.wezterm",
                "Vivaldi-stable",
              ]
            },
            {
              "x": 75,
              "y": 0,
              "width": 25
              "height": 100,
              "applications": [
                "Slack",
              ]
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

# Updates KDE settings that aren't correct.
export def settings [] {
  $env.LOG_CATEGORY = "setup kde settings"

  if (which kwriteconfig6 | is-empty) {
    log warning "kwriteconfig6 not found"
    return
  }

  if (which kreadconfig6 | is-empty) {
    log warning "kreadconfig6 not found"
    return
  }

  for $value in (values) {
    let existing_value = ^kreadconfig6 --file $value.0 --group $value.1 --key $value.2

    if $existing_value != $value.3 {
      log info $"Setting ($value.0)/($value.1)/($value.2) to ($value.3)"
      ^kwriteconfig6 --file $value.0 --group $value.1 --key $value.2 $value.3
    }
  }
}
