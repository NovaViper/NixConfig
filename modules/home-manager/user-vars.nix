{ config, lib, pkgs, ... }:
with lib;

let
  inherit (lib) mkOption types;
  cfg = config.environment.desktop;
in {
  options.variables = {
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
    };
  };

  /* config = mkMerge [
       (mkIf (cfg.machine.buildType == "desktop") {
         # KDE specific stuff
       })

       (mkIf (cfg.machine.buildType == "laptop") {
         # Specifc stuff
       })
     ];
  */
}
