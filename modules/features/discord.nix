{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "discord" {
  home.packages = with pkgs;
    if (lib.conds.isWayland config)
    then [discord-wayland vesktop]
    else [discord];

  # make vesktop autostart properly
  create.configFile."autostart/vesktop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Vencord
    Comment=Vencord autostart script
    Exec=sh -c "${pkgs.vesktop}/bin/vesktop --start-minimized"
    Terminal=false
    StartupNotify=false
  '';
}
