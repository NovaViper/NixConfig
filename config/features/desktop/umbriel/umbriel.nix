{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # tesseractLanguages = [
  #   "eng"
  # ]
  # ++ lib.optionals (isFull) [
  #   "deu"
  #   "fra"
  #   "ita"
  #   "spa"
  # ];
in
{
  imports = [ inputs.umbriel.nixosModules.default ];

  features.desktop.type = "umbriel";
  features.desktop.startAgent = true;
  features.desktop.askpassProgram = lib.getExe pkgs.kdePackages.ksshaskpass;

  # Enable Umbriel and configure it
  programs.umbriel.enable = true;
  hm.programs.umbriel = {
    enable = true;
    package = config.programs.umbriel.package;
    settings = {
      general = {
        mod_key = "Super";
        show_cheatsheet = false;
        focus_on_activate = true;
      };
      # Optional per-machine outputs and Noctalia-generated compositor colors.
      include.optional.files = [
        "monitors.toml"
        "noctalia.toml"
      ];
      input = {
        keyboard = {
          options = "ctrl:nocaps";
          numlock_toggle = true;
        };
        touchpad = {
          tap = true;
          natural_scroll = true;
        };
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
        };
      };
      # Similar to KDE Plasma
      # layout.mode = "stacking";
      appearance.title_bar.mode = "on";
      hot_corners.top_left = {
        enabled = true;
        action = "overview-open";
      };
      events.lid_close = "noctalia msg session lock-and-suspend";
    };
  };

  # NOTE: Noctalia wiki specifies specific services need to be enabled for Noctalia
  # - Network Manager is enabled in the desktop feature
  # - Bluetooth is optionally imported with the bluetooth feature
  # - Audio — required by Noctalia's volume/audio widget and screencast audio
  services.dbus.enable = true;
  security.polkit.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  security.rtkit.enable = true;

  environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

  # XDG portals — file dialogs, screenshots, screencasts
  xdg.portal = {
    wlr.enable = lib.mkForce false;
    extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
    config.umbriel = {
      default = [
        "umbriel"
        "kde"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = "kde";
      "org.freedesktop.impl.portal.ScreenCast" = "umbriel";
      "org.freedesktop.impl.portal.Screenshot" = "umbriel";
      "org.freedesktop.impl.portal.Secret" = lib.singleton "kwallet";
    };
  };

  # Setup mime associations
  hm.xdg.mimeApps = {
    defaultApplications = {
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
      "x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
    };
    associations.added."x-scheme-handler/tel" = [ "org.kde.kdeconnect.handler.desktop" ];
  };

  # wdisplays setup the monitors profile file, Kanshi restores it on login
  hm.services.kanshi.enable = true;
  hm.systemd.user.services.kanshi.Service.ExecStartPre =
    pkgs.writeShellScript "prepare-kanshi-config" ''
      umask 077
      ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.hm.xdg.configHome}/kanshi"}
      ${pkgs.coreutils}/bin/touch ${lib.escapeShellArg "${config.hm.xdg.configHome}/kanshi/config"}
    '';
  hm.dconf.settings."network/cycles/wdisplays".save-kanshi-config = true;

  # Enable fancy app launcher
  hm.programs.vicinae = {
    enable = true;
    systemd.enable = true;
    systemd.autoStart = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      # Apps
      kdePackages.gwenview
      qalculate-gtk
      qalculate-qt
      kdePackages.okular
      zed-editor
      # File Manager
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.ark
      # Color picker
      hyprpicker

      # Utilities/Libraries
      ddcutil
      xwayland
      xdg-utils
      wayland-utils
      wdisplays # Display manager
    ]
    ++ lib.optionals (config.vars.desktop.profile == "full") [
      clinfo
      mesa-demos
      vulkan-tools
    ];

  # Needed for various stuff
  hm.programs.mpv.enable = true;

  # Enable kdeconnect service and add network ports
  hm.services.kdeconnect = {
    enable = true;
    indicator = true;
  };
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
