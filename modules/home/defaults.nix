{
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.variables;
in {
  options.variables = {
    defaultTerminal = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    defaultBrowser = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    defaultTextEditor = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf ((lib.conds.runsDesktop osConfig) && cfg.defaultTerminal != null) {
      home.sessionVariables.TERMINAL = cfg.defaultTerminal;

      modules.${cfg.defaultTerminal}.enable = true;
    })

    (lib.mkIf ((lib.conds.runsDesktop osConfig) && cfg.defaultBrowser != null) {
      modules.${cfg.defaultBrowser}.enable = true;
    })

    (lib.mkIf (cfg.defaultTextEditor != null) {
      modules.${cfg.defaultTextEditor}.enable = true;
    })

    {
      assertions = [
        {
          assertion = osConfig.modules.desktop.enable && cfg.defaultTerminal != null;
          message = "variables.defaultTerminal must be defined when modules.desktop is enabled!";
        }

        {
          assertion = osConfig.modules.desktop.enable && cfg.defaultBrowser != null;
          message = "variables.defaultBrowser must be defined when modules.desktop is enabled!";
        }
      ];
    }
  ];
}
