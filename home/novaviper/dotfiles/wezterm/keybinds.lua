local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

-- Taken from https://github.com/yutkat/dotfiles/ AND https://github.com/theopn/dotfiles/
-- Tmux settings
M.minimal_keybindings = {
  -- Zoom Control
  { key = "=",        mods = "CTRL",       action = act.IncreaseFontSize },
  { key = "=",        mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = "-",        mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "-",        mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
  { key = "0",        mods = "CTRL",       action = act.ResetFontSize },
  { key = "0",        mods = "CTRL|SHIFT", action = act.ResetFontSize },

  -- Clipboard Management
  { key = "c",        mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
  { key = "v",        mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
  { key = "Insert",   mods = "SHIFT",      action = act.PasteFrom "PrimarySelection" },

    -- Command Palette
  { key = "Enter",    mods = "ALT",        action = act.ActivateCommandPalette },
}
-- Full Key Bindings
M.full_keybindings = {
  -- Send C-a when pressing C-a twice
  { key = "a",     mods = "LEADER|CTRL", action = act.SendKey { key = "a", mods = "CTRL" } },
  -- General Keys
  { key = "r",     mods = "LEADER",      action = act.ReloadConfiguration },
  { key = "Q",     mods = "LEADER",      action = act.QuitApplication },
  { key = "z",     mods = "LEADER",      action = act.TogglePaneZoomState },
  { key = "Enter", mods = "ALT",         action = act.ToggleFullScreen },

  -- Key Table Mappings
  {
    key = "r",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = "resize_pane",
      one_shot = false,
      timeout_miliseconds = 3000,
      replace_current = false,
    },
  },
  {
    key = "m",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = "move_pane",
      one_shot = false,
      timeout_miliseconds = 3000,
      replace_current = false,
    },
  },
  { key = "Enter", mods = "ALT",    action = act.ActivateCommandPalette },


  ---- Vim Mode Config
  { key = "Enter", mods = "LEADER", action = act.ActivateCopyMode },
  {
    key = "k",
    mods = "ALT|CTRL",
    action = act.Multiple({ act.CopyMode("ClearSelectionMode"), act.ActivateCopyMode, act.ClearSelection }),
  },

  -- Zoom Control
  { key = "=",        mods = "CTRL",       action = act.IncreaseFontSize },
  { key = "=",        mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = "-",        mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "-",        mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
  { key = "0",        mods = "CTRL",       action = act.ResetFontSize },
  { key = "0",        mods = "CTRL|SHIFT", action = act.ResetFontSize },

  -- Clipboard Management
  { key = "c",        mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
  { key = "v",        mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
  { key = "Insert",   mods = "SHIFT",      action = act.PasteFrom "PrimarySelection" },

  -- Pane/Tab keybindings
  ---- General
  ------ Rotate Panes
  { key = "Space",    mods = "LEADER",     action = act.RotatePanes "Clockwise" },
  ------ Show the pane selection mode, but have it swap the active and selected panes
  { key = "q",        mods = "LEADER",     action = act.PaneSelect { mode = "SwapWithActive" } },
  ------ Kill Pane
  { key = "x",        mods = "LEADER",     action = act.CloseCurrentPane { confirm = true } },
  ------ Kill Pane
  { key = "X",        mods = "LEADER",     action = act.CloseCurrentTab { confirm = true } },

  ---- Spawn Tab/Window
  { key = "C",        mods = "LEADER",     action = act.SpawnWindow },
  { key = "c",        mods = "LEADER",     action = act.SpawnTab "CurrentPaneDomain" },

  ---- Splits
  { key = "-",        mods = "LEADER",     action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "\\",       mods = "LEADER",     action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },

  -- Scrollback
  { key = "PageUp",   mods = "CTRL",       action = act.ActivateTabRelative(-1) },
  { key = "PageUp",   mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
  { key = "PageDown", mods = "SHIFT",      action = act.ScrollByPage(1) },
  { key = "PageDown", mods = "CTRL",       action = act.ActivateTabRelative(1) },
  { key = "PageDown", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },

  -- Lastly, workspace
  --{ key = "f", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },--]]
}
-- Add keybindings for tab navigiation LEADER + (0-9)
for i = 1, 9 do
  table.insert(M.full_keybindings, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1)
  })
end

M.key_tables = {
  move_pane = {
    { key = "LeftArrow",  mods = "NONE", action = act.ActivatePaneDirection "Left" },
    { key = "h",          mods = "NONE", action = act.ActivatePaneDirection "Left" },
    { key = "DownArrow",  mods = "NONE", action = act.ActivatePaneDirection "Down" },
    { key = "j",          mods = "NONE", action = act.ActivatePaneDirection "Down" },
    { key = "UpArrow",    mods = "NONE", action = act.ActivatePaneDirection "Up" },
    { key = "k",          mods = "NONE", action = act.ActivatePaneDirection "Up" },
    { key = "RightArrow", mods = "NONE", action = act.ActivatePaneDirection "Right" },
    { key = "l",          mods = "NONE", action = act.ActivatePaneDirection "Right" },
    { key = "Escape",     mode = "NONE", action = "PopKeyTable" },
    { key = "Enter",      mode = "NONE", action = "PopKeyTable" },
  },
  resize_pane = {
    { key = "LeftArrow",  mode = "NONE", action = act.AdjustPaneSize { "Left", 1 } },
    { key = "h",          mode = "NONE", action = act.AdjustPaneSize { "Left", 1 } },
    { key = "DownArrow",  mode = "NONE", action = act.AdjustPaneSize { "Down", 1 } },
    { key = "j",          mode = "NONE", action = act.AdjustPaneSize { "Down", 1 } },
    { key = "UpArrow",    mode = "NONE", action = act.AdjustPaneSize { "Up", 1 } },
    { key = "k",          mode = "NONE", action = act.AdjustPaneSize { "Up", 1 } },
    { key = "RightArrow", mode = "NONE", action = act.AdjustPaneSize { "Right", 1 } },
    { key = "l",          mode = "NONE", action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape",     mode = "NONE", action = "PopKeyTable" },
    { key = "Enter",      mode = "NONE", action = "PopKeyTable" },
  },
  copy_mode = {
    {
      key = "Escape",
      mods = "NONE",
      action = act.Multiple({
        act.ClearSelection,
        act.CopyMode("ClearPattern"),
        act.CopyMode("Close"),
      }),
    },
    { key = "q",          mode = "NONE", action = act.CopyMode("Close") },
    -- Move cursor
    { key = "LeftArrow",  mode = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "h",          mode = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "DownArrow",  mode = "NONE", action = act.CopyMode("MoveDown") },
    { key = "j",          mode = "NONE", action = act.CopyMode("MoveDown") },
    { key = "UpArrow",    mode = "NONE", action = act.CopyMode("MoveUp") },
    { key = "k",          mode = "NONE", action = act.CopyMode("MoveUp") },
    { key = "RightArrow", mode = "NONE", action = act.CopyMode("MoveRight") },
    { key = "l",          mode = "NONE", action = act.CopyMode("MoveRight") },
    -- Move word
    { key = "RightArrow", mode = "ALT",  action = act.CopyMode("MoveForwardWord") },
    { key = "f",          mode = "ALT",  action = act.CopyMode("MoveForwardWord") },
    { key = "w",          mode = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "LeftArrow",  mode = "ALT",  action = act.CopyMode("MoveBackwardWord") },
    { key = "b",          mode = "ALT",  action = act.CopyMode("MoveBackwardWord") },
    { key = "b",          mode = "NONE", action = act.CopyMode("MoveBackwardWord") },
    {
      key = "e",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("MoveRight"),
        act.CopyMode("MoveForwardWord"),
        act.CopyMode("MoveLeft"),
      }),
    },
    -- Move start/end
    { key = "0",          mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
    { key = "$",          mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "$",          mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "e",          mods = "CTRL",  action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "m",          mods = "ALT",   action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^",          mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^",          mods = "NONE",  action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "a",          mods = "CTRL",  action = act.CopyMode("MoveToStartOfLineContent") },
    -- Select
    { key = "phys:Space", mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v",          mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    {
      key = "v",
      mods = "SHIFT",
      action = act({
        Multiple = {
          act.CopyMode("MoveToStartOfLineContent"),
          act.CopyMode({ SetSelectionMode = "Cell" }),
          act.CopyMode("MoveToEndOfLineContent"),
        },
      }),
    },
    -- Copy
    {
      key = "y",
      mods = "NONE",
      action = act({
        Multiple = {
          act.CopyTo("ClipboardAndPrimarySelection"),
          act.CopyMode("Close"),
        },
      }),
    },
    {
      key = "y",
      mods = "SHIFT",
      action = act({
        Multiple = {
          act.CopyMode({ SetSelectionMode = "Cell" }),
          act.CopyMode("MoveToEndOfLineContent"),
          act.CopyTo("ClipboardAndPrimarySelection"),
          act.CopyMode("Close"),
        },
      }),
    },
    -- Scroll
    { key = "G",        mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "G",        mods = "NONE",  action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "g",        mods = "NONE",  action = act.CopyMode("MoveToScrollbackTop") },
    { key = "H",        mods = "NONE",  action = act.CopyMode("MoveToViewportTop") },
    { key = "H",        mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
    { key = "M",        mods = "NONE",  action = act.CopyMode("MoveToViewportMiddle") },
    { key = "M",        mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "L",        mods = "NONE",  action = act.CopyMode("MoveToViewportBottom") },
    { key = "L",        mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
    { key = "o",        mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "O",        mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "O",        mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "PageUp",   mods = "NONE",  action = act.CopyMode("PageUp") },
    { key = "PageDown", mods = "NONE",  action = act.CopyMode("PageDown") },
    { key = "b",        mods = "CTRL",  action = act.CopyMode("PageUp") },
    { key = "f",        mods = "CTRL",  action = act.CopyMode("PageDown") },
    {
      key = "Enter",
      mods = "NONE",
      action = act.CopyMode("ClearSelectionMode"),
    },
    -- Search
    { key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
    {
      key = "n",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("NextMatch"),
        act.CopyMode("ClearSelectionMode"),
      }),
    },
    {
      key = "N",
      mods = "SHIFT",
      action = act.Multiple({
        act.CopyMode("PriorMatch"),
        act.CopyMode("ClearSelectionMode"),
      }),
    },
  },
  search_mode = {
    { key = "Escape",    mods = "NONE", action = act.CopyMode("Close") },
    {
      key = "Enter",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("ClearSelectionMode"),
        act.ActivateCopyMode,
      }),
    },
    { key = "p",         mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "n",         mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "r",         mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "/",         mods = "NONE", action = act.CopyMode("ClearPattern") },
    { key = "u",         mods = "CTRL", action = act.CopyMode("ClearPattern") },
    { key = 'PageUp',    mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
    { key = 'PageDown',  mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
    { key = 'UpArrow',   mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
  }
}

M.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act({ CompleteSelection = "PrimarySelection" }),
  },
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act({ CompleteSelection = "Clipboard" }),
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = "OpenLinkAtMouseCursor",
  },
}


return M
