{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  wezterm = pkgs.inputs.wezterm;
in {
  #   xdg.configFile = mkIf (builtins.pathExists ./dotfiles/wezterm) (mkMerge [
  #   {"wezterm/keybinds.lua".source = utils.linkDots "wezterm/keybinds.lua";}
  #   (mkIf (!config.programs.tmux.enable) {
  #     "wezterm/on.lua".source = utils.linkDots "wezterm/on.lua";
  #   })
  # ]);

  xdg.mimeApps = let
    defaultApplications = {
      "mimetype" = "wezterm.desktop";
      "application/x-terminal-emulator" = "wezterm.desktop";
      "x-terminal-emulator" = "wezterm.desktop";
    };
  in
    lib.mkIf (myLib.utils.getUserVars "defaultTerminal" config == "wezterm") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  programs.wezterm = {
    enable = true;
    package = wezterm;
    enableZshIntegration = true;
  };

  /*
  programs.wezterm.extraConfig = ''
      local keybinds = require("keybinds")
      ${
        if (config.programs.tmux.enable)
        then ""
        else ''require("on")''
      }

      -- This table will hold the configuration, provides clearer error messages
      local config = wezterm.config_builder()

      -- Use default shell
      -- default_prog = {  },

      -- Updates are handled by NixOS
      config.check_for_updates = false

      ${
        if (config.programs.tmux.enable)
        then ''
          -- Disable tab bar, handled by tmux
          config.enable_tab_bar = false
        ''
        else ""
      }

      -- Make the starting window a good bit larger
      config.initial_cols = ${
        if (config.variables.machine.buildType == "laptop")
        then "120"
        else "160"
      }
      config.initial_rows = ${
        if (config.variables.machine.buildType == "laptop")
        then "30"
        else "40"
        }

      -- Enable audible bell
      config.audible_bell = "SystemBeep"

      -- Make cursor fancy
      config.animation_fps = 60
      config.cursor_blink_rate = 800
      config.default_cursor_style = "BlinkingBlock"

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
      ${
        if (config.programs.tmux.enable)
        then ''
          config.keys = keybinds.minimal_keybindings
        ''
        else ''
          config.leader = { key = "a", mods = "CTRL", timeout_miliseconds = 1000 }
          config.keys = keybinds.full_keybindings
          config.key_tables = keybinds.key_tables
        ''
      }
       --config.mouse_bindings = keybinds.mouse_bindings

      -- and finally, return the configuration to wezterm
      return config
    '';
  */
}
