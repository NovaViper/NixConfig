{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkRemovedOptionModule mkMerge mkIf mkDefault mkForce optionals types;
  inherit (pkgs) libsForQt5 kdePackages;
  cfg = config.variables;
  cfgde = config.variables.desktop;
  cfgma = config.variables.machine;
  desktopX = config.services.xserver.desktopManager;
  desktopW = config.services.desktopManager;
in {
  imports = [
    (mkRemovedOptionModule ["variables" "desktop" "useWayland"] ''
      The corresponding option has been removed in favor of using a string option
      type instead of boolean. This is for upcoming Wayland integration from many
      desktop environments. Please use variables.desktop.displayManager to set
      which display manager your system will use.
    '')
  ];

  options.variables = {
    username = mkOption {
      type = types.str;
      default = "";
      example = "johndoe";
      description = ''
        Keeps track of the name of your user, useful for looking up the username for other settings in the flake.
      '';
    };
    useVR = mkOption {
      type = types.bool;
      default = false;
      example = "true";
      description = ''
        Install necessary fixes to make SteamVR work on the system.
      '';
    };
    useKonsole = mkOption {
      type = types.bool;
      default = false;
      example = "true";
      description = ''
        Install KDE's Konsole and Yakuake applications and include configuration files
      '';
    };
    desktop = {
      environment = mkOption {
        type = types.str;
        default = "";
        example = "kde";
        description = ''
          Determines what desktop environment you are using, setting this will make the config enable DE specific options.
        '';
      };
      displayManager = mkOption {
        type = types.nullOr (types.enum ["wayland" "x11"]);
        default = null;
        example = "wayland";
        description = ''
          Determines what display manager you are using, setting this will make the config enable display-manager specific options. Also toggles various tweaks depending on the variables.desktop.environment variable

          Available values are wayland and x11
        '';
      };
    };
    machine = {
      buildType = mkOption {
        type = types.nullOr (types.enum ["desktop" "laptop" "server"]);
        default = null;
        example = "desktop";
        description = ''
          Type of machine the computer is.

          Available values are desktop, laptop, and server. Null assumes ISO or VM builds
        '';
      };
      motherboard = mkOption {
        type = types.nullOr (types.enum ["amd" "intel" "arm"]);
        default = null;
        example = "intel";
        description = ''
          Motherboard platform that the computer is using.
          Available values are amd, intel, and arm.
          Null assumes ISO or VM builds
        '';
      };
      gpu = mkOption {
        type = types.nullOr (types.enum ["nvidia" "intel" "amd"]);
        default = null;
        example = "amd";
        description = ''
          Type of graphics card the the computer is running.

          Available values are nvidia, intel, and amd. Null assumes custom GPU (or none at all for ISO builds)
        '';
      };
    };
  };

  /*
  options.variables = mkOption {
    type = types.attrs;
    default = { };
    description = ''
      Used to store various important variables throughout the flake
    '';
  };
  */

  config = mkIf (cfg != null) (mkMerge [
    (mkIf (cfg.machine.gpu == "nvidia") {
      nixpkgs.config.cudaSupport = mkForce true;
    })
    (mkIf (cfg.machine.gpu == "amd") {
      nixpkgs.config.rocmSupport = mkForce true;
    })

    (mkIf cfg.useVR {
      assertions = [
        {
          assertion = config.programs.steam.enable;
          message = "You need to enable Steam, since all of the necessary libraries are bundled with Steam";
        }
      ];
    })
    (mkIf (cfgde.displayManager == "x11") {
      warnings =
        if (desktopW.plasma6.enable)
        then [
          ''
            You have enabled the X11 session with KDE Plasma 6; which does not fully support the X11 session
            This may result in a broken SDDM session and thus booting into text mode!
          ''
        ]
        else [];
    })
    {
      services = mkMerge [
        # Enable Wacom touch drivers
        (mkIf (cfgma.buildType == "laptop") {
          xserver.wacom.enable = mkDefault config.services.xserver.enable;
        })
        {
          displayManager = mkIf (cfgde.environment == "kde") (mkMerge [
            # Make SDDM use Wayland when wanting to run Wayland as the display manager reguardless of which KDE version
            (mkIf (cfgde.displayManager == "wayland") {
              sddm.wayland.enable = true;
            })
            # Make the SDDM use Wayland session when on KDE Plasma 5
            (mkIf
              (desktopX.plasma5.enable && cfgde.displayManager == "wayland") {
                defaultSession = "plasmawayland";
              })
            # Make SDDM use X11 when on KDE Plasma 6
            (mkIf (desktopW.plasma6.enable && cfgde.displayManager == "x11") {
              defaultSession = "plasmax11";
            })
          ]);
        }
      ];

      # Automatic screen orentiation for laptops
      hardware.sensor.iio.enable =
        if (cfgma.buildType == "laptop")
        then true
        else false;

      environment = {
        # Remove Konsole if `useKonsole` is NOT enabled (only for KDE since it's already included) KDE Plasma 5 version
        plasma5.excludePackages = [] ++ optionals (!cfg.useKonsole && cfgde.environment == "kde" && desktopX.plasma5.enable) [libsForQt5.konsole];

        # Remove Konsole if `useKonsole` is NOT enabled (only for KDE since it's already included) KDE Plasma 6 version
        plasma6.excludePackages = [] ++ optionals (!cfg.useKonsole && cfgde.environment == "kde" && desktopW.plasma6.enable) [kdePackages.konsole];

        systemPackages = mkMerge [
          # Download Konsole if `useKonsole` is used on a DE that DOESN'T include Konsole (like KDE);
          (mkIf (cfg.useKonsole && cfgde.environment != "kde")
            [kdePackages.konsole])
          # download Yakuake if `useKonsole` is used on a DE that DOES include Konsole (like KDE); switch between QT6 and QT5 versions of Yakuake depending on KDE Plasma version
          (mkIf (cfg.useKonsole
            && cfgde.environment == "kde"
            && desktopX.plasma5.enable) [libsForQt5.yakuake])
          (mkIf (cfg.useKonsole
            && cfgde.environment == "kde"
            && desktopW.plasma6.enable) [kdePackages.yakuake])
        ];
      };
    }
  ]);
}
