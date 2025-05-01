{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    if osConfig.features.useWayland then
      [
        discord-wayland
        vesktop
      ]
    else
      [ discord ];

  # make vesktop autostart properly
  xdg.configFile."autostart/vesktop.desktop".text = ''
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
