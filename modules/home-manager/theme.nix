{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkRemovedOptionModule mkMerge mkBefore literalExpression types;
  cfg = config.theme;
  cfgapp = cfg.app;

  iconThemeModule = types.submodule {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.papirus-icon-theme";
        description = ''
          Package providing the theme. This package will be installed to your profile. If 'null', then the theme is assumed to be already available in your profile.
        '';
      };
      name = mkOption {
        type = types.str;
        default = "";
        example = "Papirus-Dark";
        description = "The symbolic name of the theme within the package without any spaces.";
      };
    };
  };

  appModule = types.submodule {
    options = {
      rio.name = mkOption {
        type = types.str;
        default = "";
        example = "3024 Night";
        description = ''
          The name of the theme within the package to use for Rio.

          See theme names: https://github.com/raphamorim/rio-terminal-themes/tree/main/themes
        '';
      };
    };
  };
in {
  options.theme = {
    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      example = literalExpression "pkgs.dracula-theme";
      description = ''
        Package providing the theme. This package will be installed to your profile. If 'null', then the theme is assumed to be already available in your profile.
      '';
    };
    name = mkOption {
      type = types.str;
      default = "";
      example = "Dracula";
      description = "The name of the theme within the package.";
    };
    nameSymbolic = mkOption {
      type = types.str;
      default = "";
      example = "dracula";
      description = "The symbolic name of the theme within the package without any spaces.";
    };
    iconTheme = mkOption {
      type = types.nullOr iconThemeModule;
      default = {};
      description = "Icon configuration options.";
    };
    app = mkOption {
      type = types.nullOr appModule;
      default = {};
      description = "App theme configuration options.";
    };
  };

  config = mkIf (cfg != null) (mkMerge [
    # Configure rio
    (mkIf (cfgapp != null && config.programs.rio.enable) {
      xdg.configFile."rio/themes/${cfgapp.rio.name}.toml".source =
        fetchGit {
          url = "https://github.com/raphamorim/rio-terminal-themes";
          rev = "9d76eb416c1cc46f959f236fdfa5479a19c0a070";
        }
        + "/themes/${cfgapp.rio.name}.toml";
      programs.rio.settings = mkBefore {
        # It makes Rio look for the specified theme in the themes folder
        # (macos and linux: ~/.config/rio/themes/dracula.toml)
        # (windows: C:\Users\USER\AppData\Local\rio\themes\dracula.toml)
        theme = "${cfgapp.rio.name}";
      };
    })
    # Configure gtk theme
    (mkIf (config.gtk.enable) {
      gtk = {
        iconTheme = mkIf (cfg.iconTheme != null) {
          name = cfg.iconTheme.name;
          package = cfg.iconTheme.package;
        };
      };
    })

    # Install the packages
    {
      home.packages = with pkgs; (mkMerge
        [(mkIf (cfg.iconTheme.package != null) [cfg.iconTheme.package])]);
    }
  ]);
}
