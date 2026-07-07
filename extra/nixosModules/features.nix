{
  config,
  lib,
  pkgs,
  options,
  username,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    mkMerge
    ;
  cfg = config.features;

  mkFeature =
    description:
    mkOption {
      type = types.nullOr types.str;
      description = "The chosen ${description}.";
    };

  mkEnumFeature =
    {
      desc,
      opts,
      default ? null,
    }:
    mkOption {
      type = types.nullOr (types.enum opts);
      description = "The chosen ${desc}.";
      inherit default;
    };

  mkBoolFeature =
    description:
    mkOption {
      type = types.bool;
      default = false;
      description = "Whether ${description} is being used.";
    };

  waylandEnv = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland,x11,windows";
    CLUTTER_BACKEND = "wayland";
    # QT_QPA_PLATFORM = "wayland";
    # LIBSEAT_BACKEND = "logind";
    XDG_SESSION_TYPE = "wayland";
    #WLR_NO_HARDWARE_CURSORS = "1";
    # _JAVA_AWT_WM_NONREPARENTING = "1";
    # GDK_SCALE = "2";
    # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
in
{

  options.features = {
    shell = mkFeature "shell, which provides some form of initExtra access";

    desktop = {
      type = mkEnumFeature {
        desc = "desktop environment";
        opts = [
          "kde"
          "niri"
          "sway"
        ];
      };
      startAgent = mkEnableOption "use OpenSSH agent";
      askpassProgram = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SSH askpass executable provided by the selected desktop.";
      };

    };

    hardware = {
      apple.enable = mkEnableOption "Apple device support";
    };

    vr = mkEnumFeature {
      desc = "virtual-reality desktop streamer";
      opts = [
        "wivrn"
      ];
    };
    development.enable = mkEnableOption "development tools";

    includeMinecraftServer = mkBoolFeature "minecraft server";

    # prompt = mkFeature "shell prompt";

    # abbreviations = mkFeature "provider of abbreviations";

    # direnv = mkFeature "program for providing direnv functionality";

    #files = mkFeature "file manager";

    #pdfs = mkFeature "PDF viewer";

    #images = mkFeature "image viewer";

    #videos = mkFeature "video viewer";

    #music = mkFeature "music player";
  };

  config = mkMerge [
    # Common
    (mkIf (cfg.desktop.type != null) {
      # FIXME: Look at this
      # users.users.${username}.extraGroups = [
      #   "video"
      #   "audio"
      # ];

      hm.home.sessionVariables = waylandEnv;

      services = {
        # Enable touchpad support
        libinput.enable = true;
        # Enable color management service
        # colord.enable = true;
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

      # NOTE This will break stuff if there is a non-wayland user on the same machine,
      #  but application launchers need this.
      environment.sessionVariables = waylandEnv;

      environment.systemPackages = with pkgs; [
        #Notifications
        libnotify

        # Install necessary wayland protocol packages
        qt5.qtwayland
        qt6.qtwayland

        # Enable guestures for touchpad
        libinput-gestures
        # Install audio configuration tools (Especially important for VR)
        pavucontrol
        pulseaudio

        # wayland stuff
        wl-clipboard
        wl-clipboard-x11

        libnotify
      ];

      # Enable the RealtimeKit system service
      security.rtkit.enable = true;

      # Disable PulseAudio
      services.pulseaudio.enable = lib.mkForce false;

      # Enable networking
      networking.networkmanager.enable = true;

      # Enable for GTK
      programs.dconf.enable = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };

      hm.xdg = {
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

        # Let Home-manager create XDG autostart entries
        autostart.enable = true;
        # Let Home-manager manage user directories
        userDirs.enable = true;
        userDirs.createDirectories = true;
      };
    })
    {
      assertions = [
        {
          assertion = (cfg.vr != null) -> (cfg.desktop.type != null);
          message = "There must be a desktop selected via features.desktop in order to use anything related to virutal reality (VR)!";
        }
      ];
    }
  ];
}
