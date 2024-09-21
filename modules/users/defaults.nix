{
  config,
  outputs,
  ...
}: {
  options = {
    defaultTerminal = outputs.lib.mkOption {
      default =
        if (outputs.lib.isDesktop' config)
        then (throw "defaultTerminal not set")
        else null;
      type = outputs.lib.types.str;
    };
    defaultBrowser = outputs.lib.mkOption {
      default =
        if (outputs.lib.isDesktop' config)
        then (throw "defaultBrowser not set")
        else null;
      type = outputs.lib.types.str;
    };
  };

  config = outputs.lib.deepMerge [
    (outputs.lib.mkIf
      ((outputs.lib.isDesktop' config) && config.defaultTerminal != null) {
        home.sessionVariables.TERMINAL = config.defaultTerminal;

        modules.${config.defaultTerminal}.enable = true;
      })
    (outputs.lib.mkIf
      ((outputs.lib.isDesktop' config) && config.defaultBrowser != null) {
        modules.${config.defaultBrowser}.enable = true;
      })
  ];
}
