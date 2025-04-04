{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.userVars;
  cfgFeat = config.features;
in {
  options.userVars = {
    username = mkOption {
      type = types.str;
      description = "The name of the current user";
      default = "";
    };
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
    homeDirectory = mkOption {
      type = types.str;
      description = ''
        The directory for the user's folders. This should only be set if it's in a non-default location.
      '';
      default = "/home/${cfg.username}";
    };
    defaultTerminal = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    defaultBrowser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    defaultEditor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config.assertions = [
    {
      assertion = (cfg.defaultTerminal != null) -> (cfgFeat.desktop != "none");
      message = "variables.defaultTerminal must be defined when modules.desktop is enabled!";
    }
    {
      assertion = (cfg.defaultBrowser != null) -> (cfgFeat.desktop != "none");
      message = "variables.defaultBrowser must be defined when modules.desktop is enabled!";
    }
  ];
}
