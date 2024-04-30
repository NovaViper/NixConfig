{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (lib) mkOption types;
  cfg = config.variables;
  cfgde = config.variables.desktop;
  cfgma = config.variables.machine;
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
        type = with types; nullOr (types.enum ["wayland" "x11"]);
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
        type = with types; nullOr (enum ["desktop" "laptop" "server"]);
        default = null;
        example = "desktop";
        description = ''
          Type of machine the computer is.

          Available values are desktop, laptop, and server. Null assumes ISO or VM builds
        '';
      };
      gpu = mkOption {
        type = with types; nullOr (enum ["nvidia" "intel" "amd"]);
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
    /*
    (mkIf (cfg.machine.buildType == "desktop") {
      # KDE specific stuff
    })

    (mkIf (cfg.machine.buildType == "laptop") {
      # Specifc stuff
    })
    */
  ];
}
