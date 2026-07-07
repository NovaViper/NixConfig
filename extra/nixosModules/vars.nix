{
  lib,
  config,
  options,
  username,
  ...
}:
let
  cfg = config.vars;
  cfgFeat = config.features;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.vars = {
    user = {
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
    };
    desktop = {
      profile = mkOption {
        type = types.nullOr (
          types.enum [
            "full"
            "minimal"
          ]
        );
        description = "What desktop profile to use. 'full' will install a full desktop environment, while 'minimal' will only install the bare minimum for a desktop.";
        default = null;
      };
    };

    apps = {
      terminal = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "The preferred terminal app";
        default = null;
      };
      browser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "The preferred internet browser app";
        default = null;
      };
      editor = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "The preferred text editor app";
        default = null;
      };
    };

    host = {
      configDirectory = lib.mkOption {
        type = types.str;
        description = "The directory of the local nixos configuration.";
        default = null;
      };
      scalingFactor = mkOption {
        type = types.number;
        description = "The scaling factor for the desktop. A scalingFactor of 1 --> 100% scaling.";
        default = 1;
      };
    };
  };

  config.assertions = [
    { assertion = cfg.host.configDirectory != null; }
    { assertion = cfg.host.scalingFactor != null; }
    {
      assertion = (cfg.apps.terminal != null) -> (cfgFeat.desktop != null);
      message = "vars.apps.terminal must be defined when features.desktop.type is set!";
    }
    {
      assertion = (cfg.apps.browser != null) -> (cfgFeat.desktop != null);
      message = "vars.apps.browser must be defined when features.desktop.type is set!";
    }
    {
      assertion = (cfg.apps.browser != null) -> (cfgFeat.desktop != null);
      message = "vars.apps.browser must be defined when features.desktop is set!";
    }
    {
      assertion = config.vars.desktop.profile == null || cfgFeat.desktop.type != null;

      message = "vars.desktop.profile requires features.desktop.type to be set.";
    }

    {
      assertion = cfgFeat.desktop.type == null || config.vars.desktop.profile != null;

      message = "features.desktop.type requires vars.desktop.profile to be set.";
    }
  ];
}
