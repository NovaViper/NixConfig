{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.variables;
  cfgde = config.variables.desktop;
  cfgma = config.variables.machine;
  desktopEnv = config.services.xserver.desktopManager;
in {
  imports = [
    (mkRemovedOptionModule [ "variables" "desktop" "useWayland" ] ''
      The corresponding option has been removed in favor of using a string option
      type instead of boolean. This is for upcoming Wayland integration from many
      desktop environments. Please use variables.desktop.displayManager to set
      which display manager your system will use.
    '')
  ];

  options.variables = {
    username = mkOption {
      type = with types; str;
      default = "";
      example = "johndoe";
      description = ''
        Keeps track of the name of your user, useful for looking up the username for other settings in the flake.
      '';
    };
    useVR = mkOption {
      type = with types; bool;
      default = false;
      example = "true";
      description = ''
        Install necessary fixes to make SteamVR work on the system.
      '';
    };
    useKonsole = mkOption {
      type = with types; bool;
      default = false;
      example = "true";
      description = ''
        Install KDE's Konsole and Yakuake applications and include configuration files
      '';
    };
    desktop = {
      environment = mkOption {
        type = with types; str;
        default = "";
        example = "kde";
        description = ''
          Determines what desktop environment you are using, setting this will make the config enable DE specific options.
        '';
      };
      displayManager = mkOption {
        type = with types; nullOr (types.enum [ "wayland" "x11" ]);
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
        type = with types; nullOr (types.enum [ "desktop" "laptop" "server" ]);
        default = null;
        example = "desktop";
        description = ''
          Type of machine the computer is.

          Available values are desktop, laptop, and server. Null assumes ISO or VM builds
        '';
      };
      motherboard = mkOption {
        type = with types; nullOr (types.enum [ "amd" "intel" "arm" ]);
        default = null;
        example = "intel";
        description = ''
          Motherboard platform that the computer is using.
          Available values are amd, intel, and arm.
          Null assumes ISO or VM builds
        '';
      };
      gpu = mkOption {
        type = with types; nullOr (enum [ "nvidia" "intel" "amd" ]);
        default = null;
        example = "amd";
        description = ''
          Type of graphics card the the computer is running.

          Available values are nvidia, intel, and amd. Null assumes custom GPU (or none at all for ISO builds)
        '';
      };
    };
  };

  /* options.variables = mkOption {
       type = with types; attrs;
       default = { };
       description = ''
         Used to store various important variables throughout the flake
       '';
     };
  */

  config = mkIf (cfg != null) (mkMerge [
    (mkIf cfg.useVR {
      assertions = [{
        assertion = config.programs.steam.enable;
        message =
          "You need to enable Steam, since all of the necessary libraries are bundled with Steam";
      }];
    })

    ({
      services.xserver = mkMerge [
        # Enable Wacom touch drivers
        (mkIf (cfgma.buildType == "laptop") {
          wacom.enable = mkDefault config.services.xserver.enable;
        })

        ({
          displayManager = mkIf (cfgde.environment == "kde") (mkMerge [
            # Make SDDM use Wayland when wanting to run Wayland as the display manager reguardless of which KDE version
            (mkIf (cfgde.displayManager == "wayland") {
              sddm.wayland.enable = true;
            })
            # Make the SDDM use Wayland session when on KDE Plasma 5
            (mkIf
              (desktopEnv.plasma5.enable && cfgde.displayManager == "wayland") {
                defaultSession = "plasmawayland";
              })
            # Make SDDM use X11 when on KDE Plasma 6
            (mkIf (desktopEnv.plasma6.enable && cfgde.displayManager == "x11") {
              defaultSession = "plasmax11";
            })
          ]);
        })
      ];

      # Automatic screen orentiation for laptops
      hardware.sensor.iio.enable =
        (if (cfgma.buildType == "laptop") then true else false);

      environment = {
        # Remove Konsole if `useKonsole` is NOT enabled (only for KDE since it's already included) KDE Plasma 5 version
        plasma5.excludePackages = with pkgs.libsForQt5;
          mkIf (!cfg.useKonsole && cfgde.environment == "kde"
            && desktopEnv.plasma5.enable) [ konsole ];

        # Remove Konsole if `useKonsole` is NOT enabled (only for KDE since it's already included) KDE Plasma 6 version
        plasma6.excludePackages = with pkgs.libsForQt5;
          mkIf (!cfg.useKonsole && cfgde.environment == "kde"
            && desktopEnv.plasma6.enable) [ konsole ];

        systemPackages = with pkgs;
          (mkMerge [
            # Download Konsole if `useKonsole` is used on a DE that DOESN'T include Konsole (like KDE);
            # download Yakuake if `useKonsole` is used on a DE that DOES include Konsole (like KDE)
            (mkIf (cfg.useKonsole && cfgde.environment != "kde")
              [ libsForQt5.konsole ])
            (mkIf (cfg.useKonsole && cfgde.environment == "kde"
              && desktopEnv.plasma5.enable) [ libsForQt5.yakuake ])
            (mkIf (cfg.useKonsole && cfgde.environment == "kde"
              && desktopEnv.plasma6.enable) [ kdePackages.yakuake ])
          ]);
      };
    })
  ]);
}
