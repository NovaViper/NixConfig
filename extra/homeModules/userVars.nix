{
  config,
  osConfig,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.userVars;
  cfgFeat = osConfig.features;
in {
  options.userVars = {
    fullName = mkOption {
      type = types.str;
      description = "Your first and last name";
      default = "";
    };
    email = mkOption {
      type = types.str;
      description = "Your email address";
      default = "";
    };
    defaultTerminal = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The preferred terminal app";
      default = null;
    };
    defaultBrowser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The preferred internet browser app";
      default = null;
    };
    defaultEditor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The preferred text editor app";
      default = null;
    };
  };

  config.assertions = [
    {
      assertion = (cfg.defaultTerminal != null) -> (cfgFeat.desktop != null);
      message = "variables.defaultTerminal must be defined when modules.desktop is enabled!";
    }
    {
      assertion = (cfg.defaultBrowser != null) -> (cfgFeat.desktop != null);
      message = "variables.defaultBrowser must be defined when modules.desktop is enabled!";
    }
  ];
}
