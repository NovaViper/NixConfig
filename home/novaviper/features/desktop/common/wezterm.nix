{ config, lib, pkgs, ... }:

{
  xdg.configFile = {
    "wezterm/keybinds.lua".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/wezterm/keybinds.lua";
    "wezterm/on.lua".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/wezterm/on.lua";
  };

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
        color_scheme = "Dracula-Offical",
        --default_prog = {  },
        check_for_updates = false,
        font = wezterm.font("MesloLGS Nerd Font"),
        font_size = 11,
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
        window_decorations = "RESIZE",
        window_background_opacity = 0.9,

        -- Dim inactive panes
        inactive_pane_hsb = {
          --saturation = 0.9,
          brightness = 0.8,
        },
        leader = { key = "a", mods = "CTRL", timeout_miliseconds = 1000 },
        keys = keybinds.default_keybinds,
        key_tables = keybinds.key_tables,
        --mouse_bindings = keybind.mouse_bindings,
      }


      -- and finally, return the configuration to wezterm
      return config
    '';
    colorSchemes.Dracula-Offical = {
      ansi = [
        "#21222c"
        "#ff5555"
        "#50fa7b"
        "#f1fa8c"
        "#bd93f9"
        "#ff79c6"
        "#8be9fd"
        "#f8f8f2"
      ];
      background = "#282a36";
      brights = [
        "#6272a4"
        "#ff6e6e"
        "#69ff94"
        "#ffffa5"
        "#d6acff"
        "#ff92df"
        "#a4ffff"
        "#ffffff"
      ];
      "compose_cursor" = "#ffb86c";
      "cursor_bg" = "#f8f8f2";
      "cursor_border" = "#f8f8f2";
      "cursor_fg" = "#282a36";
      foreground = "#f8f8f2";
      "scrollbar_thumb" = "#44475a";
      "selection_bg" = "rgba(26.666668% 27.843138% 35.294117% 50%)";
      "selection_fg" = "rgba(0% 0% 0% 0%)";
      split = "#6272a4";
      indexed = { };
      "tab_bar" = {
        background = "#282a36";
        "active_tab" = {
          "bg_color" = "#bd93f9";
          "fg_color" = "#282a36";
          intensity = "Normal";
          italic = false;
          strikethrough = false;
          underline = "None";
        };
        "inactive_tab" = {
          "bg_color" = "#282a36";
          "fg_color" = "#f8f8f2";
          intensity = "Normal";
          italic = false;
          strikethrough = false;
          underline = "None";
        };
        "inactive_tab_hover" = {
          "bg_color" = "#6272a4";
          "fg_color" = "#f8f8f2";
          intensity = "Normal";
          italic = true;
          strikethrough = false;
          underline = "None";
        };
        "new_tab" = {
          "bg_color" = "#282a36";
          "fg_color" = "#f8f8f2";
          intensity = "Normal";
          italic = false;
          strikethrough = false;
          underline = "None";
        };
        "new_tab_hover" = {
          "bg_color" = "#ff79c6";
          "fg_color" = "#f8f8f2";
          intensity = "Normal";
          italic = true;
          strikethrough = false;
          underline = "None";
        };
      };
    };
  };

  home.sessionVariables.TERMINAL = "wezterm";

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
}
