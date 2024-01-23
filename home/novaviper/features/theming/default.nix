{ config, lib, pkgs, inputs, ... }:
let inherit (inputs.nix-colors) colorSchemes;
in {
  colorscheme = colorSchemes.dracula;

  theme = {
    package = pkgs.dracula-theme;
    name = "Dracula";
    nameSymbolic = "dracula";
    app = {
      rio.name = config.theme.name;
      wezterm.name = "Dracula (Offical)";
      fzf.colors = {
        fg = "#f8f8f2"; # foreground
        bg = "#282a36"; # background
        hl = "#bd93f9"; # purple
        "fg+" = "#f8f8f2"; # foreground
        "bg+" = "#44475a"; # current-line
        "hl+" = "#bd93f9"; # purple
        info = "#ffb86c"; # orange
        prompt = "#50fa7b"; # green
        pointer = "#ff79c6"; # pink
        marker = "#ff79c6"; # pink
        spinner = "#ffb86c"; # orange
        header = "#6272a4"; # comment
      };
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
  };

  # KDE Theming
  programs.plasma = lib.mkIf (config.variables.desktop.environment == "kde") {
    workspace = {
      #wallpaper = "";
      lookAndFeel = "${config.theme.name}";
      cursorTheme = "${config.theme.cursorTheme.name}";
      iconTheme = "${config.theme.iconTheme.name}";
      colorScheme = "DraculaPurple";
      theme = "default";
    };

    configFile = {
      "gtk-3.0/settings.ini"."Settings"."gtk-theme-name" =
        "${config.theme.name}";
      "gtk-4.0/settings.ini"."Settings"."gtk-theme-name" =
        "${config.theme.name}";
    };
  };
}
