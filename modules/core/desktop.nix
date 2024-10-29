{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop;
  waylandEnv = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "x11";
    CLUTTER_BACKEND = "wayland";
    # QT_QPA_PLATFORM = "wayland";
    # LIBSEAT_BACKEND = "logind";
    XDG_SESSION_TYPE = "wayland";
    #WLR_NO_HARDWARE_CURSORS = "1";
    # _JAVA_AWT_WM_NONREPARENTING = "1";
    # GDK_SCALE = "2";
    # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
in {
  options.modules.desktop = {
    enable = lib.mkEnableOption "Enable desktop configurations";
    x11.enable = lib.mkEnableOption "Enable X11 integration" // {default = true;};
    wayland.enable = lib.mkEnableOption "Enable wayland integration";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # X11 Configs
    (lib.mkIf cfg.x11.enable {
      # Enable the X11 windowing system.
      services.xserver = {
        enable = true;

        # Configure keymap in X11
        xkb = {
          layout = "us";
          variant = "";
          options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";
        };

        # Remove xterm terminal
        excludePackages = with pkgs; [xterm];
      };

      # Install installation
      environment.systemPackages = with pkgs; [
        # X11
        xorg.xkbutils
        xorg.xkill
        xorg.libxcb
      ];
    })
    # Wayland Configs
    (lib.mkIf cfg.wayland.enable {
      environment = {
        # NOTE This will break stuff if there is a non-wayland user on the same machine,
        #  but application launchers need this.
        sessionVariables = waylandEnv;
        # Install necessary wayland protocol packages
        systemPackages = with pkgs; [
          #xorg.xeyes
          kdePackages.xwaylandvideobridge
          libsForQt5.qt5.qtwayland
          qt6.qtwayland
        ];
      };

      hm.home.sessionVariables = waylandEnv;
    })

    # Common
    {
      modules.fonts.enable = true;
      services = {
        # Enable touchpad support
        libinput.enable = true;
        # Enable color management service
        colord.enable = true;
        # Enable pipewire
        pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
        };
      };
      environment.systemPackages = with pkgs; [
        #Notifications
        libnotify

        #PDF
        poppler

        # Enable guestures for touchpad
        libinput-gestures
        # Install audio configuration tools (Especially important for VR)
        pavucontrol
        pulseaudio
      ];

      # Enable the RealtimeKit system service
      security.rtkit.enable = true;

      # Disable PulseAudio
      hardware.pulseaudio.enable = lib.mkForce false;

      # Enable networking
      networking.networkmanager.enable = true;

      # Enable for GTK
      programs.dconf.enable = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;
        extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      };

      hm.xdg = {
        /*
          portal = {
          enable = true;
          xdgOpenUsePortal = true;
        };
        */
        # Don't generate config at the usual place.
        # Allow desktop applications to write their file association
        # preferences to this file.
        configFile."mimeapps.list".enable = false;
        # Home-manager also writes xdg-mime-apps configuration to the
        # "deprecated" location. Desktop applications will look in this
        # list for associations, if no association was found in the
        # previous config file.
        dataFile."applications/mimeapps.list".force = true;
        mimeApps.enable = true;
      };
    }
  ]);
}
