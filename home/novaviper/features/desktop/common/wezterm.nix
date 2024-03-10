{ config, lib, pkgs, ... }:

{
  xdg.mimeApps = {
    associations = {
      added = {
        "mimetype" = "wezterm.desktop";
        "application/x-terminal-emulator" = "wezterm.desktop";
        "x-terminal-emulator" = "wezterm.desktop";
      };
    };
    defaultApplications = {
      "mimetype" = "wezterm.desktop";
      "application/x-terminal-emulator" = "wezterm.desktop";
      "x-terminal-emulator" = "wezterm.desktop";
    };
  };

  home.sessionVariables.TERMINAL = "wezterm";

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
       -- This table will hold the configuration, provides clearer error messages
       local config = wezterm.config_builder()

       -- Theme set by theme module
       config.color_scheme = "${config.theme.app.wezterm.name}"

       -- Use default shell
       -- default_prog = {  },

       -- Updates are handled by NixOS
       config.check_for_updates = false

       -- Setup fallback font
       config.font = wezterm.font_with_fallback({"MesloLGS Nerd Font"})
       config.font_size = 12.0

       -- Disable tab bar, handled by tmux
       config.enable_tab_bar = false

       -- Make the starting window a good bit larger
       config.initial_cols = ${
         if (config.variables.machine.buildType == "laptop") then
           "120"
         else
           "160"
       }
       config.initial_rows = ${
         if (config.variables.machine.buildType == "laptop") then "30" else "40"
       }


       -- Enable audible bell
       config.audible_bell = "SystemBeep"

       -- Make cursor fancy
       config.animation_fps = 60
       config.cursor_blink_rate = 800
       config.default_cursor_style = "BlinkingBlock"
       config.window_background_opacity = 0.8

       config.enable_kitty_keyboard = false
       config.enable_scroll_bar = false
       config.enable_wayland = true

       -- Dim inactive panes
       config.inactive_pane_hsb = {
         --saturation = 0.9
         brightness = 0.8,
       }

       -- disable most of the keybindings because I want them to use Tmux. Enable the few I want to use
       config.disable_default_key_bindings = true
       local act = wezterm.action
       config.keys = {
          { key = "=",        mods = "CTRL",       action = act.IncreaseFontSize },
          { key = "=",        mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
          { key = "-",        mods = "CTRL",       action = act.DecreaseFontSize },
          { key = "-",        mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
          { key = "0",        mods = "CTRL",       action = act.ResetFontSize },
          { key = "0",        mods = "CTRL|SHIFT", action = act.ResetFontSize },
          { key = "p",        mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
          { key = "c",        mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
          { key = "C",        mods = "CTRL",       action = act.CopyTo "Clipboard" },
          { key = "v",        mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
          { key = "C",        mods = "CTRL",       action = act.PasteFrom "Clipboard" },
          { key = "Insert",   mods = "SHIFT",      action = act.PasteFrom "PrimarySelection" },
          { key = "F11",      mods = "NONE",       action = act.ToggleFullScreen },
       }

       config.mouse_bindings = {
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

       -- and finally, return the configuration to wezterm
       return config
    '';
  };
}
