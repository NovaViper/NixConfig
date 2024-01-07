{ config, lib, pkgs, ... }:

{
  xdg = {
    configFile = {
      "wezterm/keybinds.lua".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/wezterm/keybinds.lua";
      "wezterm/on.lua".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/wezterm/on.lua";
    };
    mimeApps = {
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
  };

  home.sessionVariables.TERMINAL = "wezterm";

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      -- Load Extra files
      local keybinds = require("keybinds")
      require("on")


      -- This table will hold the configuration.
      local config = {}

      -- In newer versions of wezterm, use the config_builder which will
      -- help provide clearer error messages
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end


      -- This is where you actually apply your config choices
      config = {
        color_scheme = "${config.theme.app.wezterm.name}",
        --default_prog = {  },
        check_for_updates = false,
        font = wezterm.font("MesloLGS Nerd Font"),
        font_size = 11,
        audible_bell = "SystemBeep",
        animation_fps = 60,
        initial_cols = 150,
        initial_rows = 40,
        cursor_blink_rate = 800,
        default_cursor_style = "BlinkingBlock",
        scrollback_lines = 5000,
        enable_scroll_bar = true,
        tab_bar_at_bottom = true,
        status_update_interval = 1000,
        use_fancy_tab_bar = false,
        enable_wayland = true,
        window_background_opacity = 0.8,

        -- Dim inactive panes
        inactive_pane_hsb = {
          --saturation = 0.9,
          brightness = 0.8,
        },

        leader = { key = "a", mods = "CTRL", timeout_miliseconds = 1000 },
        --front_end = "OpenGL",
        -- disable most of the keybindings because I want them to use the LEADER keys.
        disable_default_key_bindings = true,
        keys = keybinds.default_keybinds,
        key_tables = keybinds.key_tables,
        mouse_bindings = keybinds.mouse_bindings,
      }


      -- and finally, return the configuration to wezterm
      return config
    '';
  };
}
