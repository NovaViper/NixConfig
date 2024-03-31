{ config, lib, pkgs, ... }:

{
  xdg = {
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
    environment = {
      COLORTERM = "truecolor";
      WINIT_X11_SCALE_FACTOR = "1";
    };
    settings = {
      # Advanced {{{
      term = "xterm-256color";
      #shell = "${pkgs.zsh}/bin/zsh --login --interactive";
      #kitty_mod = "ctrl+shift";
      #startup_session = "default.conf";
      repaint_delay = 0;
      # }}}

      # Terminal Bell {{{
      enable_audio_bell = "yes";
      visual_bell_duration = "0.0";
      bell_on_tab = "🔔 ";
      linux_bell_theme = "__ocean";
      bell_path =
        "${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/bell-window-system.oga";
      # }}}

      # Cursor {{{
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      # }}}

      # Scrollback {{{
      scrollback_lines = 5000;
      # }}}

      # Mouse {{{
      show_hyperlink_targets = "yes";
      copy_on_select = "yes";
      paste_actions = "quote-urls-at-prompt,confirm-if-large";
      focus_follows_mouse = "yes";
      mouse_hide_wait = 0;
      # }}}

      # Window Layout {{{
      remember_window_size = "yes";
      initial_window_width =
        if (config.variables.machine.buildType == "laptop") then 1000 else 1920;
      initial_window_height =
        if (config.variables.machine.buildType == "laptop") then 700 else 1080;

      enabled_layouts = "tall:bias=65;full_size=1;mirrored=false";
      # }}}

      # Color Scheme {{{
      dynamic_background_opacity = "yes";
      # }}}
    };
    extraConfig = "";
    keybindings = {
      #: Window management {{{
      #: New window
      #"kitty_mod+enter" = "new_window";
      #"f7" = "focus_visible_window";
      #"f8" = "swap_with_window";

      #"ctrl+left" = "resize_window narrower";
      #"ctrl+right" = "resize_window wider";
      #"ctrl+up" = "resize_window taller";
      #"ctrl+down" = "resize_window shorter";

      # reset all windows in the tab to default sizes
      #"kitty_mod+z" = "resize_window reset";

      # }}}

      #: Tab Management {{{
      #"ctrl+t" = "new_tab";
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
      "f9" = "show_kitty_doc overview";

      #: Toggle fullscreen
      "f11" = "toggle_fullscreen";

      #: Toggle maximized
      "f10" = "toggle_maximized";

      #: Edit config file
      #"f2" = "launch --type=tab emacsclient -nw ~/.config/kitty/kitty.conf";

      #: Reload kitty.conf
      "f5" =
        "combine : load_config_file : launch --type=overlay --hold --allow-remote-control kitty @ send-text 'kitty config reloaded'";
      #"ctrl+r" = "combine : load_config_file : launch --type=overlay --hold --allow-remote-control kitty @ send-text 'kitty config reloaded'";
      #: Debug kitty configuration
      "f6" = "debug_config";
      # }}}
    };
  };
}
