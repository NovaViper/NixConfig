{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.noctalia.nixosModules.default ];
  programs.noctalia.enable = true;
  programs.noctalia.package = pkgs.inputs.noctalia.default;

  # Use the configured MPV when enabled, otherwise provide it for picker thumbnails.
  hm.home.packages =
    (with pkgs; [
      mpvpaper
      socat
    ])
    ++ lib.optional (!config.hm.programs.mpv.enable) pkgs.mpv;

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "umbriel";
      appearance = {
        password_style = "random";
      };
    };
  };

  hm.programs.noctalia =
    let
      time_format = "{:%-I:%M:%S %p}";
      date_format = "{:%a, %-d %b %Y}";
    in
    {
      enable = true;
      systemd.enable = true;
      package = pkgs.inputs.noctalia.default;
      settings = {
        plugins.enabled = [
          "noctalia/umbriel-companion"
          "noctalia/mpvpaper"
          "noctalia/wallhaven"
        ];
        storage.key_source = "secret-service";
        control_center.width = 1100; # I want it wide!
        shell = {
          inherit time_format date_format;
          corner_radius_scale = 0;
          polkit_agent = true;
          password_style = "random";
          umbriel_overview_type_to_launch_enabled = true;
          screenshot = {
            # Keep the capture/editor workflow; use defaults for PNG, freeze, save, and copy.
            annotate = true;
            directory = "${config.hm.xdg.userDirs.pictures}/Screenshots";
            filename_pattern = "Screenshot_%Y-%m-%d_%H-%M-%S";
          };
        };
        bar.default = {
          margin_ends = 0;
        };
        widget = {
          battery = {
            display_mode = "graphic";
            scale = 0.8;
            show_label = false;
          };
          clock.format = "${date_format}{:%t}${time_format}";
          network.show_label = false;
          privacy = {
            active_color = "error";
            hide_inactive = true;
            icon_spacing = 12;
          };
          tray.drawer = true;
          volume.show_label = false;
          # workspaces.hide_when_empty = true;
        };
        # Unity-inspired launcher: fixed-size icons against the left screen edge.
        dock = {
          enabled = true;
          position = "left";
          margin_edge = 0;
          radius = 0;
          auto_hide = false;
          reserve_space = true;
          magnification = false;
          inactive_scale = 1.0;
          inactive_opacity = 1.0;
          show_running = true;
          show_dots = true;
          launcher_position = "start";
          pinned = [
            "firefox"
            "org.kde.dolphin"
            config.vars.apps.terminal.desktopFile
            "vesktop"
            "steam"
          ];
        };
        theme = {
          mode = "dark";
          source = "builtin";
          # builtin = "Catppuccin";
          #pure_black_dark TODO: Setup oled feature option for oled screens!
        };
        lockscreen = {
          enabled = true;
          blurred_desktop = false;
          transition_duration = 300; # Was WAY too slow before..
          blur_intensity = 0.5;
          tint_intensity = 0.3;
        };

        # wallpaper = {
        #   enabled = true;
        #   default.path = "/path/to/wallpapers/wallpaper.png";
        # };
      };
    };
}
