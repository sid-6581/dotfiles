--- @diagnostic disable: no-unknown
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local is_linux = wezterm.target_triple:find("linux") ~= nil

-- UI

local scheme = wezterm.get_builtin_color_schemes()["GruvboxDarkHard"]
scheme.background = "#1d2021"
config.color_schemes = {
  GruvboxDarkHard = scheme,
}

config.front_end = "WebGpu"
config.color_scheme = "GruvboxDarkHard"
config.default_cursor_style = "SteadyBar"
config.freetype_load_flags = "DEFAULT"
config.max_fps = 240
config.animation_fps = 240
config.custom_block_glyphs = true
config.font = wezterm.font({
  family = "JetBrainsMono Nerd Font",
})

config.adjust_window_size_when_changing_font_size = false
config.font_size = 9.5
config.command_palette_font_size = 12

config.window_decorations = is_linux and "TITLE | RESIZE" or "INTEGRATED_BUTTONS | RESIZE"

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
  font_size = 9.5,
}

config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = "none",
      fg_color = "#c0c0c0",
      -- "Half", "Normal" or "Bold" intensity
      intensity = "Normal",
      -- "None", "Single" or "Double" underline
      underline = "None",
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = "none",
      fg_color = "#808080",
    },
    inactive_tab_hover = {
      bg_color = "none",
      fg_color = "#909090",
      italic = true,
    },
    new_tab = {
      bg_color = "none",
      fg_color = "#808080",
    },
    new_tab_hover = {
      bg_color = "none",
      fg_color = "#909090",
      italic = true,
    },
  },
}

config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 1.0,
}

if is_linux then
  config.default_domain = "nu"
else
  config.default_domain = "wsl"
end

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
  local pane = tab.active_pane
  local domain_name = pane.domain_name == config.default_domain and "" or " (" .. pane.domain_name .. ")"
  return tab.tab_index + 1 .. ": " .. pane.title .. domain_name
end)

wezterm.on(
  "format-window-title",
  function(tab, _pane, _tabs, _panes, _config)
    return tab.active_pane.title
  end
)

config.skip_close_confirmation_for_processes_named = {
  "bash",
  "cmd.exe",
  "conhost.exe",
  "env.exe",
  "fedoraremix.exe",
  "fish",
  "nu",
  "nu.exe",
  "powershell.exe",
  "pwsh.exe",
  "sh",
  "tmux",
  "wsl.exe",
  "wslhost.exe",
  "zsh",
  "zsh.exe",
}

-- Profiles

if is_linux then
  config.exec_domains = {
    wezterm.exec_domain("nu", function(cmd)
      local args = { "nu", "-i" }

      if cmd.args then
        table.insert(args, "-c")
        for _, arg in ipairs(cmd.args) do
          table.insert(args, arg)
        end
      end

      cmd.args = args
      return cmd
    end),
  }
else
  config.exec_domains = {
    wezterm.exec_domain("nu", function(cmd)
      local args = { "nu", "-i" }

      if cmd.args then
        table.insert(args, "-c")
        for _, arg in ipairs(cmd.args) do
          table.insert(args, arg)
        end
      end

      cmd.args = args
      return cmd
    end),

    wezterm.exec_domain("pwsh", function(cmd)
      local args = { "pwsh.exe", "-nologo" }
      for _, arg in ipairs(cmd.args or {}) do
        table.insert(args, arg)
      end

      cmd.args = args
      return cmd
    end),
  }

  config.wsl_domains = {
    {
      name = "wsl",
      distribution = "fedoraremix",
      default_cwd = "~",
      default_prog = { "bash", "-lc", "nu", "-i" },
    },
  }
end

local launch_default = {
  label = config.default_domain,
  domain = { DomainName = config.default_domain },
}

local launch_nushell = {
  label = "nu",
  domain = { DomainName = "nu" },
}

local launch_powershell = {
  label = "pwsh",
  domain = { DomainName = "pwsh" },
}

config.launch_menu = {
  launch_default,
  launch_nushell,
  launch_powershell,
}

-- Keys

config.allow_win32_input_mode = false
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = false

config.keys = {
  -- New tabs
  { key = "!", mods = "SHIFT|CTRL", action = act.SpawnCommandInNewTab(launch_default) },
  { key = "#", mods = "SHIFT|CTRL", action = act.SpawnCommandInNewTab(launch_powershell) },
  { key = "@", mods = "SHIFT|CTRL", action = act.SpawnCommandInNewTab(launch_nushell) },
  { key = "t", mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
  -- New panes
  { key = "!", mods = "SHIFT|CTRL|ALT", action = act.SplitVertical(launch_default) },
  { key = "#", mods = "SHIFT|CTRL|ALT", action = act.SplitVertical(launch_powershell) },
  { key = "@", mods = "SHIFT|CTRL|ALT", action = act.SplitVertical(launch_nushell) },
  { key = "|", mods = "SHIFT|CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "_", mods = "SHIFT|CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  -- Tab selection/moving
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
  { key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) },
  { key = "PageDown", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },
  { key = "PageUp", mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
  -- Misc
  { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
  { key = "f", mods = "SHIFT|CTRL", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "k", mods = "SHIFT|CTRL", action = act.ClearScrollback("ScrollbackOnly") },
  { key = "d", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
  { key = "m", mods = "SHIFT|CTRL", action = act.Hide },
  { key = "n", mods = "SHIFT|CTRL", action = act.SpawnWindow },
  { key = "p", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
  { key = "r", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },
  { key = "u", mods = "SHIFT|CTRL", action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },
  { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
  { key = "w", mods = "SHIFT|CTRL", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "x", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
  { key = "z", mods = "SHIFT|CTRL", action = act.TogglePaneZoomState },
  -- { key = "phys:Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
  -- Scrolling
  { key = "UpArrow", mods = "SHIFT", action = act.ScrollByLine(-1) },
  { key = "DownArrow", mods = "SHIFT", action = act.ScrollByLine(1) },
  { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
  -- Pane selection/sizing
  { key = "h", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
  { key = "h", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
  { key = "l", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
  { key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
  { key = "k", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },
  { key = "j", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },
}

config.key_tables = {
  copy_mode = {
    { key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
    { key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
    { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
    { key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
    { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
    { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    { key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
    { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
    { key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
    { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
    { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
    { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
    { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
    { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
    { key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
    { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "g", mods = "CTRL", action = act.CopyMode("Close") },
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
    { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "y", mods = "NONE", action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },
    { key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
    { key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
    { key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
    { key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
  },

  search_mode = {
    { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
    { key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
    { key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
  },
}

return config
