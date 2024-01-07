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
      type = types.str;
      #default = "";
      example = "johndoe";
      description = ''
        Keeps track of the name of your user, useful for looking up the username for other settings in the flake.
      '';
    };

    useVR = mkOption {
      type = types.bool;
      #default = false;
      example = "false";
      description = ''
        Install necessary fixes to make SteamVR work on the system.
      '';
    };

    useKonsole = mkOption {
      type = types.bool;
      #default = false;
      example = "false";
      description = ''
        Install KDE's Konsole and Yakuake applications and include configuration files
      '';
    };

    desktop = {
      environment = mkOption {
        type = types.str;
        #default = "";
        example = "kde";
        description = ''
          Determines what desktop environment you are using, setting this will make the config enable DE specific options.
        '';
      };

      useWayland = mkOption {
        type = types.bool;
        #default = "";
        example = "false";
        description = ''
          Enable Wayland as the default display manager for the system, option toggles various different tweaks depending on the variables.desktop.environment variable
        '';
      };
    };
    machine = {
      buildType = mkOption {
        type = types.nullOr (types.enum [ "desktop" "laptop" "server" ]);
        #default = "";
        example = "desktop";
        description = ''
          Type of machine the computer is. Available values are desktop, laptop, and server
        '';
      };
      motherboard = mkOption {
        type = types.nullOr (types.enum [ "amd" "intel" "arm" ]);
        #default = "";
        example = "intel";
        description = ''
          Motherboard platform that the computer is using.
        '';
      };
      gpu = mkOption {
        type = types.nullOr (types.enum [ "nvidia" "intel" "amd" ]);
        #default = "";
        example = "desktop";
        description = ''
          Type of gpu the the computer is running. Available values are nvidia, intel, and amd
        '';
      };
    };
  };

  /* options.variables = mkOption {
       type = types.attrs;
       default = { };
       description = ''
         Used to store various important variables throughout the flake
       '';
     };
  */

  config = mkMerge [
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
  ];
}
