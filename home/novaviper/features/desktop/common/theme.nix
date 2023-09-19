{ config, pkgs, lib, ... }:

{
  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme.name = "Dracula";
  };

  qt = lib.mkMerge [
    (lib.mkIf (config.environment.desktop == "kde") {
      enable = true;
      platformTheme = "kde";
    })
    (lib.mkIf (config.environment.desktop == "xfce") {
      enable = true;
      platformTheme = "qtct";
      style = {
        name = "Dracula";
        package = pkgs.dracula-theme;
      };
    })
  ];

  home.packages = with pkgs; [ dracula-icon-theme dracula-theme ];
}
