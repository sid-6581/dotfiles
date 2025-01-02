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
    ["ksmserverrc", "General", "confirmLogout", "false"],
    ["ksmserverrc", "General", "loginMode", "emptySession"],
    ["kwinrc", "EdgeBarrier", "CornerBarrier", "false"],
    ["kwinrc", "TabBox", "HighlightWindows", "false"],
    ["kwinrc", "Effect-overview", "BorderActivate", "9"],
    ["kwinrc", "Windows", "ElectricBorderMaximize", "false"],
    ["kwinrc", "Windows", "ElectricBorderTiling", "false"],
    ["plasmaparc", "General", "AudioFeedback", "false"],
    ["systemsettingsrc", "systemsettings_sidebar_mode", "HighlightNonDefaultSettings", "true"],
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
