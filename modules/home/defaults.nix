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
      default =
        if osConfig.modules.desktop.enable
        then (throw "defaultTerminal not set")
        else null;
      type = lib.types.str;
    };
    defaultBrowser = lib.mkOption {
      default =
        if osConfig.modules.desktop.enable
        then (throw "defaultBrowser not set")
        else null;
      type = lib.types.str;
    };
    defaultTextEditor = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf
      ((lib.conds.runsDesktop osConfig) && cfg.defaultTerminal != null) {
        home.sessionVariables.TERMINAL = cfg.defaultTerminal;

        modules.${cfg.defaultTerminal}.enable = true;
      })
    (lib.mkIf
      ((lib.conds.runsDesktop osConfig) && cfg.defaultBrowser != null) {
        modules.${cfg.defaultBrowser}.enable = true;
      })
    (lib.mkIf
      (cfg.defaultTextEditor != null) {
        modules.${cfg.defaultTextEditor}.enable = true;
      })
  ];
}
