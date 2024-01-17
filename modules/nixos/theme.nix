{ config, lib, pkgs, ... }:
with lib;
let
  inherit (lib) mkOption types;
  cfg = config.theme;
  cursorThemeModule = types.submodule {
    options = {
      package = mkOption {
        type = with types; nullOr package;
        default = null;
        example = literalExpression "pkgs.capitaine-cursors";
        description = ''
          Package providing the theme. This package will be installed to your profile. If 'null', then the theme is assumed to be already available in your profile.
        '';
      };
      name = mkOption {
        type = with types; str;
        default = "";
        example = "capitaine-cursors-white";
        description =
          "The symbolic name of the theme within the package with no spaces.";
      };
      size = mkOption {
        type = with types; nullOr int;
        default = null;
        example = 30;
        description = ''
          The size of the cursor.
        '';
      };
    };
  };
in {
  options.theme = {
    package = mkOption {
      type = with types; nullOr package;
      default = null;
      example = literalExpression "pkgs.dracula-theme";
      description = ''
        Package providing the theme. This package will be installed to your profile. If 'null', then the theme is assumed to be already available in your profile.
      '';
    };
    name = mkOption {
      type = with types; str;
      default = "";
      example = "Dracula";
      description = "The name of the theme within the package.";
    };
    consoleColors = mkOption {
      type = with types; listOf (strMatching "[[:xdigit:]]{6}");
      default = [ ];
      example = [
        "002b36"
        "dc322f"
        "859900"
        "b58900"
        "268bd2"
        "d33682"
        "2aa198"
        "eee8d5"
        "002b36"
        "cb4b16"
        "586e75"
        "657b83"
        "839496"
        "6c71c4"
        "93a1a1"
        "fdf6e3"
      ];
      description = lib.mdDoc ''
        The 16 colors palette used by the virtual consoles.
        Leave empty to use the default colors.
        Colors must be in hexadecimal format and listed in
        order from color 0 to color 15.
      '';
    };
    #consoleTheme.enable = mkEnableOption "TTY config generation the theming module";
    cursorTheme = mkOption {
      type = types.nullOr cursorThemeModule;
      default = { };
      description = "Cursor configuration options.";
    };
  };

  config = mkIf (cfg != null) (mkMerge [({
    # Make the module's console colors equal to the NixOS one
    console.colors = mkIf (cfg.consoleColors != [ ]) cfg.consoleColors;
    services.xserver.displayManager = (mkMerge [
      (mkIf (config.variables.desktop.environment == "kde") {
        sddm.settings.Theme = (mkMerge [
          #({ Font = "Noto Sans,10,-1,0,50,0,0,0,0,0"; })
          (mkIf (cfg.cursorTheme != null) {
            CursorTheme = cfg.cursorTheme.name;
            CursorSize = cfg.cursorTheme.size;
          })
        ]);
      })
    ]);
    # Install all packages for the themes
    environment.systemPackages = with pkgs;
      (mkMerge [
        (mkIf (cfg.package != null) [ cfg.package ])
        (mkIf (cfg.cursorTheme.package != null) [ cfg.cursorTheme.package ])
      ]);
  })]);
}
