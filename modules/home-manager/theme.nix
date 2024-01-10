{ config, lib, pkgs, ... }:
with lib;
let
  inherit (lib) mkOption types;
  cfg = config.theme;
  cfgapp = cfg.app;
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
      example = "Dracula";
      description = "The name of the theme within the package.";
    };
    nameSymbolic = mkOption {
      type = types.str;
      example = "dracula";
      description =
        "The symbolic name of the theme within the package without any spaces.";
    };
    cursorTheme = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.capitaine-cursors";
        description = ''
          Package providing the theme. This package will be installed to your profile. If 'null', then the theme is assumed to be already available in your profile.
        '';
      };
      name = mkOption {
        type = types.str;
        example = "capitaine-cursors-white";
        description =
          "The symbolic name of the theme within the package without any spaces.";
      };
      size = mkOption {
        type = types.int;
        default = null;
        example = 30;
        description = ''
          The size of the cursor.
        '';
      };
    };
    iconTheme = {
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
        example = "Papirus-Dark";
        description =
          "The symbolic name of the theme within the package without any spaces.";
      };
    };
    app = {
      rio.name = mkOption {
        type = types.str;
        example = "3024 Night";
        description = ''
          The name of the theme within the package to use for Rio.

          See theme names: https://github.com/raphamorim/rio-terminal-themes/tree/main/themes
        '';
      };
      fzf.colors = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = literalExpression ''
          {
            bg = "#1e1e1e";
            "bg+" = "#1e1e1e";
            fg = "#d4d4d4";
            "fg+" = "#d4d4d4";
          }
        '';
        description = ''
          Color scheme options added to `FZF_DEFAULT_OPTS`. See
          <https://github.com/junegunn/fzf/wiki/Color-schemes>
          for documentation.
        '';
      };
      wezterm.name = mkOption {
        type = types.str;
        example = "Dracula (Offical)";
        description = ''
          The name of the theme within the package to use for Wezterm.

          See theme names: https://wezfurlong.org/wezterm/colorschemes
        '';
      };
    };

  };

  config = mkIf (cfg != null) (let
    theme-name = optionalString (cfg.name != null) cfg.name;
    theme-name-symbolic =
      optionalString (cfg.nameSymbolic != null) cfg.nameSymbolic;
    cursor-name =
      optionalString (cfg.cursorTheme != null && cfg.cursorTheme.name != null)
      cfg.cursorTheme.name;
    cursor-size =
      optionalString (cfg.cursorTheme != null && cfg.cursorTheme.size != null)
      cfg.cursorTheme.size;
    icon-name =
      optionalString (cfg.iconTheme != null && cfg.iconTheme.name != null)
      cfg.iconTheme.name;
    rio-name = optionalString (cfgapp.rio.name != null) cfgapp.rio.name;
    fzf-colors = optionals (cfgapp.fzf.colors != [ ]) cfgapp.fzf.colors;
  in mkMerge [
    # Import theme for Alacritty!
    # See themes at https://github.com/alacritty/alacritty-theme/tree/master/themes
    (mkIf (config.programs.alacritty.enable) {
      home.packages = with pkgs; [ alacritty-theme ];
      programs.alacritty.settings = mkBefore {
        import = [ "${pkgs.alacritty-theme}/${cfg.nameSymbolic}.yaml" ];
      };
    })
    # Configure btop
    (mkIf (config.programs.btop.enable) {
      programs.btop.settings = mkBefore {
        #* Themes should be placed in "../share/btop/themes" relative to binary or "$HOME/.config/btop/themes"
        color_theme =
          "${pkgs.btop}/share/btop/themes/${theme-name-symbolic}.theme";
      };
    })
    # Configure rio
    (mkIf (cfgapp != null && config.programs.rio.enable) {
      xdg.configFile."rio/themes/${rio-name}.toml".source = fetchGit {
        url = "https://github.com/raphamorim/rio-terminal-themes";
        rev = "9d76eb416c1cc46f959f236fdfa5479a19c0a070";
      } + "/themes/${rio-name}.toml";
      programs.rio.settings = mkBefore {
        # It makes Rio look for the specified theme in the themes folder
        # (macos and linux: ~/.config/rio/themes/dracula.toml)
        # (windows: C:\Users\USER\AppData\Local\rio\themes\dracula.toml)
        theme = "${rio-name}";
      };
    })
    # Configure the colors for fzf
    (mkIf (cfgapp != null && config.programs.fzf.enable) {
      programs.fzf.colors = fzf-colors;
    })
    # Configure the cursor theme
    (mkIf (cfg.cursorTheme != null && config.variables.desktop.environment
      != null) {
        home.pointerCursor = {
          package = cfg.cursorTheme.package;
          name = cursor-name;
          size = cursor-size;
          gtk.enable = config.gtk.enable;
          x11.enable = true;
        };
      })
    # Configure gtk theme
    (mkIf (config.gtk.enable) {
      gtk = {
        theme = {
          name = cfg.name;
          package = cfg.package;
        };
        iconTheme = mkIf (cfg.iconTheme != null) {
          name = icon-name;
          package = cfg.iconTheme.package;
        };
      };
    })
    # Configure qt theme
    (mkIf (config.qt.enable && config.qt.platformTheme != "kde") {
      qt.style = {
        name = theme-name;
        package = cfg.package;
      };
    })

    # Install the packages
    ({
      home.packages = with pkgs;
        (mkMerge [
          (mkIf (cfg.package != null) [ cfg.package ])
          (mkIf (cfg.cursorTheme.package != null) [ cfg.cursorTheme.package ])
          (mkIf (cfg.iconTheme.package != null) [ cfg.iconTheme.package ])
        ]);
    })
  ]);
}
