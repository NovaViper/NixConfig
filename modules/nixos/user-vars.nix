{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.variables;
  cfgde = config.variables.desktop;
  cfgma = config.variables.machine;
in {
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
      useWayland = mkOption {
        type = with types; bool;
        default = false;
        example = "true";
        description = ''
          Enable Wayland as the default display manager for the system, option toggles various different tweaks depending on the variables.desktop.environment variable
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
            # Make SDDM use Wayland
            (mkIf cfgde.useWayland {
              defaultSession = "plasmawayland";
              sddm.wayland.enable = true;
            })
          ]);
        })
      ];

      # Automatic screen orentiation for laptops
      hardware.sensor.iio.enable =
        (if (cfgma.buildType == "laptop") then true else false);

      environment = {
        # Remove Konsole if `useKonsole` is NOT enabled (only for KDE since it's already included)
        plasma5.excludePackages = with pkgs.libsForQt5;
          mkIf (!cfg.useKonsole && cfgde.environment == "kde") [ konsole ];

        systemPackages = with pkgs;
          (mkMerge [
            # Add virtual keyboard for touchscreen laptops (Wayland only)
            (mkIf (cfgde.useWayland && cfgma.buildType == "laptop")
              [ maliit-keyboard ])

            # Download Konsole if `useKonsole` is used on a DE that DOESN'T include Konsole (like KDE);
            # download Yakuake if `useKonsole` is used on a DE that DOES include Konsole (like KDE)
            (mkIf (cfg.useKonsole && cfgde.environment != "kde")
              [ libsForQt5.konsole ])
            (mkIf (cfg.useKonsole && cfgde.environment == "kde")
              [ libsForQt5.yakuake ])
          ]);
      };
    })
  ]);
}
