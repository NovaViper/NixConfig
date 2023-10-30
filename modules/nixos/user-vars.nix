{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.variables;
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
        Install necessary fixes to make SteamVR work on the system..
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
          Type of machine the computer is Available values are desktop, laptop, and server
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

    # Remove Konsole if 'useKonsole is NOT enabled (only for KDE since it's already included)'
    (mkIf (cfg.desktop.environment == "kde") {
      environment = {
        systemPackages = with pkgs;
          lib.mkIf cfg.useKonsole [ libsForQt5.yakuake ];
        plasma5 = mkIf (!cfg.useKonsole) {
          excludePackages = with pkgs.libsForQt5; [ konsole ];
        };
      };
    })

    # Download Konsole if `useKonsole` is used on a DE that DOESN'T include Konsole (like KDE)
    (mkIf (cfg.useKonsole) {
      environment = mkIf (!cfg.desktop.environment == "kde") {
        systemPackages = with pkgs.libsForQt5; [ konsole ];
      };
    })

    (mkIf cfg.desktop.useWayland {
      # KDE specific stuff
      services.xserver = mkIf (cfg.desktop.environment == "kde") {
        displayManager = {
          defaultSession = "plasmawayland";
          sddm.wayland.enable = true;
        };
      };
    })

    (mkIf (cfg.machine.buildType == "desktop") {
      # KDE specific stuff
    })

    (mkIf (cfg.machine.buildType == "laptop") {

      # Automatic screen orentiation
      hardware.sensor.iio.enable = true;

      # Enable Wacom touch drivers
      services.xserver.wacom.enable =
        lib.mkDefault config.services.xserver.enable;

      environment = mkIf (cfg.desktop.useWayland) {
        # Add virtual keyboard for touchscreen
        systemPackages = with pkgs; [ maliit-keyboard ];
      };
    })
  ];
}
