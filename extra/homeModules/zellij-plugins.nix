# Credit goes to PerchunPak for this module!
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.zellij;
in
{
  options = {
    programs.zellij = {
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = lib.literalExpression ''
          with pkgs.zellijPlugins; [ ghost harpoon nvim-nav-plugin ]
        '';
        description = "List of Zellij plugins";
      };
    };
  };

  config = {
    # on every plugin update, zellij asks for permissions again, because
    # the plugin path has changed (=/nix/store path has changed)
    # to avoid that, we symlink all plugins to `.config/zellij/plugins` and
    # use those paths
    xdg.configFile = lib.listToAttrs (
      lib.map (
        plugin:
        let
          pluginName = lib.removePrefix "zellij-" plugin.pname;
        in
        {
          name = "zellij/plugins/${pluginName}.wasm";
          value.source = plugin;
        }
      ) cfg.plugins
    );

    programs.zellij = {
      package = pkgs.zellij.override {
        extraPackages = lib.concatLists (lib.map (x: x.runtimeDeps or [ ]) cfg.plugins);
      };

      settings = {
        # define plugin aliases
        plugins = lib.mkIf (cfg.plugins != [ ]) (
          lib.mergeAttrsList (
            lib.map (
              plugin:
              let
                pluginName = lib.removePrefix "zellij-" plugin.pname;
                pluginPath = "${config.xdg.configHome}/zellij/plugins/${pluginName}.wasm";
              in
              {
                ${pluginName}._props = {
                  location = "file:${pluginPath}";
                };
              }
            ) cfg.plugins
          )
        );
        # auto-load plugins on start
        load_plugins = lib.mkIf (cfg.plugins != [ ]) {
          _children = lib.map (plugin: {
            ${lib.removePrefix "zellij-" plugin.pname} = [ ];
          }) cfg.plugins;
        };
      };
    };
  };
}
