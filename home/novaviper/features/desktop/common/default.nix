{ lib, pkgs, outputs, ... }:

{
  imports = [
    ./font.nix
    #./theme.nix
    ./discord.nix
    ./cider.nix
    ./jellyfin.nix
    #./firefox.nix
    ./vivaldi.nix
    ./backup.nix
    ./alacritty.nix
  ];

  home.sessionVariables = {
    GTK_USE_PORTAL = "1";
    #QT_STYLE_OVERRIDE = "kvantum";
  };

  xdg.mimeApps.enable = true;

  # Make mimeapps.list be overriden by default
  xdg.configFile."mimeapps.list".force = true;
}
