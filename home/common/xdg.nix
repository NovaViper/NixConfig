{
  config,
  lib,
  pkgs,
  ...
}: {
  xresources.path = lib.mkForce "${config.xdg.configHome}/.Xresources";
  gtk.gtk2.configLocation = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";

  home.shellAliases = {
    wget = ''wget --hsts-file="${config.xdg.dataHome}/wget-hsts"'';
  };
}
