{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.variables;
in {
  options.variables = {
    useVR = mkOption {
      type = types.bool;
      #default = false;
      example = "false";
      description = ''
        Install necessary fixes to make SteamVR work on the system.
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
      gpu = mkOption {
        type = types.nullOr (types.enum [ "nvidia" "intel" "amd" ]);
        #default = "";
        example = "desktop";
        description = ''
          Type of gpu the the computer is running. Available values are nvidia, intel, and amd
        '';
      };
    };

    useKonsole = mkOption {
      type = types.bool;
      #default = false;
      example = "false";
      description = ''
        Install KDE's Konsole and Yakuake applications and include configuration files
      '';
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
