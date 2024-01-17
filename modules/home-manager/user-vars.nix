{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.variables;
  cfgde = config.variables.desktop;
  cfgma = config.variables.machine;
in {
  options.variables = {
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
        type = with types; nullOr (enum [ "desktop" "laptop" "server" ]);
        default = null;
        example = "desktop";
        description = ''
          Type of machine the computer is.

          Available values are desktop, laptop, and server. Null assumes ISO or VM builds
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

  config = mkMerge [
    (mkIf (cfg.useKonsole) { home.sessionVariables.TERMINAL = "konsole"; })
    /* (mkIf (cfg.machine.buildType == "desktop") {
         # KDE specific stuff
       })

       (mkIf (cfg.machine.buildType == "laptop") {
         # Specifc stuff
       })
    */
  ];
}
