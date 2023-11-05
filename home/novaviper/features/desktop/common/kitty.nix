{ config, lib, pkgs, ... }:

{
  xdg = {
    configFile = {
      "kitty/default.conf".source = ../../../dots/kitty/default.conf;
    };
    mimeApps = {
      associations = {
        added = {
          "mimetype" = "kitty.desktop";
          "application/x-terminal-emulator" = "kitty.desktop";
          "x-terminal-emulator" = "kitty.desktop";
        };
      };
      defaultApplications = {
        "mimetype" = "kitty.desktop";
        "application/x-terminal-emulator" = "kitty.desktop";
        "x-terminal-emulator" = "kitty.desktop";
      };
    };
  };

  home.sessionVariables.TERMINAL = "kitty";

  programs.kitty = {
    enable = true;
    theme = "Dracula";
    shellIntegration = {
      enableZshIntegration = true;
      #mode = "";
    };
    environment = {
      TERM = "xterm-256color";
      COLORTERM = "truecolor";
      WINIT_X11_SCALE_FACTOR = "1";
    };
    font = {
      package = pkgs.meslo-lgs-nf;
      name = "MesloLGS Nerd Font";
      #size = "";
    };
    keybindings = {
      #: Window management {{{
      #: New window
      "kitty_mod+enter" = "new_window";
      "f7" = "focus_visible_window";
      "f8" = "swap_with_window";

      "pctrl+left" = "resize_window narrower";
      "ctrl+right" = "resize_window wider";
      "ctrl+up" = "resize_window taller";
      "ctrl+down" = "resize_window shorter";

      # reset all windows in the tab to default sizes
      "kitty_mod+z" = "resize_window reset";

      # }}}

      #: Tab Management {{{
      "ctrl+t" = "new_tab";
      # }}}

      # Font Sizes {{{
      #: Increase font size
      "ctrl+equal" = "change_font_size all +1.0";

      #: Decrease font size
      "ctrl+minus" = "change_font_size all -1.0";

      "ctrl+0" = "change_font_size all 0";
      # }}}

      #: Miscellaneous {{{
      #: Show documentation
      "f1" = "show_kitty_doc overview";

      #: Toggle fullscreen
      "f11" = "toggle_fullscreen";

      #: Toggle maximized
      "f10" = "toggle_maximized";

      #: Edit config file
      "f2" = "launch --type=tab emacsclient -nw ~/.config/kitty/kitty.conf";

      #: Reload kitty.conf
      "f5" =
        "combine : load_config_file : launch --type=overlay --hold --allow-remote-control kitty @ send-text 'kitty config reloaded'";
      "ctrl+r" =
        "combine : load_config_file : launch --type=overlay --hold --allow-remote-control kitty @ send-text 'kitty config reloaded'";
      #: Debug kitty configuration
      "f6" = "debug_config";
      # }}}
    };
    settings = {

      # Advanced {{{
      #term = "xterm-256color";
      #shell = "${pkgs.zsh}/bin/zsh --login --interactive";
      #kitty_mod = "ctrl+shift";
      startup_session = "default.conf";
      # }}}

      # Cursor {{{
      cursor_shape = "underline";
      cursor_blink_interval = "-1";
      # }}}

      # Scrollback {{{
      scrollback_lines = 2000;
      # }}}

      # Mouse {{{
      show_hyperlink_targets = "yes";
      copy_on_select = "yes";
      paste_actions = "quote-urls-at-prompt";
      focus_follows_mouse = "yes";
      # }}}

      # Window Layout {{{
      initial_window_width = 1920;
      initial_window_height = 1080;

      enabled_layouts = "*";
      # }}}

      # Window Layout {{{
      tab_bar_style = "powerline";
      tab_powerline_style = "angled";
      tab_activity_symbol = "x";
      # }}}

      # Coloe Scheme {{{
      dynamic_background_opacity = "yes";
      # }}}
    };
    extraConfig = "";
  };
}
