{
  config,
  lib,
  pkgs,
  ...
}:
{
  hm.home.packages = with pkgs; [
    # discord-wayland
    vesktop
  ];

  # make vesktop autostart properly
  hm.xdg.configFile."autostart/vesktop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Vencord
    Comment=Vencord autostart script
    Exec=sh -c "${lib.getExe pkgs.vesktop} --start-minimized"
    Terminal=false
    StartupNotify=false
  '';
}
