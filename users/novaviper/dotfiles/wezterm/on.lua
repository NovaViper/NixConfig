local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- Startup
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  -- Create a right side pane
  local right_pane = pane:split { direction = "Right", size = 0.3 }
  -- Split right pane into two, with new pane on bottom
  local bottom_pane = right_pane:split { direction = "Bottom", args = { "cava" } }
  -- Activate primary left pame
  pane:activate()
end)

-- Reload Config Toast Notification
--[[
wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification('wezterm', 'configuration reloaded!', nil, 1000)
end)
--]]

-- Modeline
wezterm.on("update-status", function(window, pane)
  -- Workspace name
  local stat = window:active_workspace()
  local stat_color = "#f7768e"
  -- It's a little silly to have workspace name all the time
  -- Utilize this to display LDR or current key table name
  if window:active_key_table() then
    stat = window:active_key_table()
    stat_color = "#7dcfff"
  end
  if window:leader_is_active() then
    stat = "LEADER"
    stat_color = "#bb9af7"
  end

  -- Battery
  local ok, battery_infos = pcall(wezterm.battery_info)

  if not ok or #battery_infos <= 0 or battery_infos[1].state == "Unknown" then
    return
  end

  local battery_info = battery_infos[1]
  local icon
  local percentage = battery_info.state_of_charge * 100

  if battery_info.state == "Charging" then
    icon = "md_battery_charging_" .. math.floor(percentage / 10 + 0.5) * 10
  elseif battery_info.state == "Discharging" then
    icon = "md_battery_" .. math.floor(percentage / 10 + 0.5) * 10
  elseif battery_info.state == "Empty" then
    icon = "md_battery_outline"
  elseif battery_info.state == "Full" then
    icon = "md_battery"
  end
  -- There're no icons for 0% and 100%.
  icon = icon:gsub("_0", "_outline"):gsub("_100", "")
  local bat = string.format("%s %.0f%% ", wezterm.nerdfonts[icon], percentage)


  -- Current working directory
  local basename = function(s)
    -- Nothing a little regex can't fix
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
  end

  -- Time
  local time = wezterm.strftime("%-m/%-d %a, %I:%M")

  -- Left status (left of the tab line)
  local left_status = {
    { Background = { Color = stat_color } },
    { Foreground = { Color = "#282a36" } },
    { Text = " " },
    { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
    { Text = " " },
  }

  -- Right status
  local right_status = {
    -- Wezterm has a built-in nerd fonts
    -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
    { Foreground = { Color = "#282a36" } },
    { Background = { Color = "#ff79c6" } },
    { Text = " " .. bat .. " " },
    --{ Background = { Color = "#50fa7b" } },
    --{ Text = " " .. wezterm.nerdfonts.md_folder .. "  " .. cwd .. " " },
    --{ Background = { Color = "#ff5555" } },
    --{ Text = " " .. wezterm.nerdfonts.fa_code .. "  " .. cmd .. " " },
    { Background = { Color = "#8be9fd" } },
    { Text = " " .. wezterm.nerdfonts.md_clock .. "  " .. time },
    { Text = " " }
  }

  window:set_left_status(wezterm.format(left_status))
  window:set_right_status(wezterm.format(right_status))


  -- Left status (left of the tab line)
  --[[window:set_left_status(wezterm.format({
    { Foreground = { Color = stat_color } },
    { Text = "  " },
    { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
    { Text = " | " },
  }))

  -- Right status
  window:set_right_status(wezterm.format({
    -- Wezterm has a built-in nerd fonts
    -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
    { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
    { Text = " | " },
    { Foreground = { Color = "#e0af68" } },
    { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
    "ResetAttributes",
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
    { Text = "  " },
  }))--]]
end)
