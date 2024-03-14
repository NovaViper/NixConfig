local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- Startup
--[[
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  -- Create a right side pane
  local right_pane = pane:split { direction = "Right", size = 0.3 }
  -- Split right pane into two, with new pane on bottom
  local bottom_pane = right_pane:split { direction = "Bottom", args = { "cava" } }
  -- Activate primary left pame
  pane:activate()
end)
--]]

-- Reload Config Toast Notification
--[[
wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification('wezterm', 'configuration reloaded!', nil, 1000)
end)
--]]
