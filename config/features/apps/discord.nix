{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.home.packages = with pkgs; [
    # discord-wayland
    vesktop
  ];

  # make vesktop autostart properly
  hm.xdg.configFile."autostart/vesktop.desktop" =
    lib.mkIf (config.features.desktop.type != "umbriel")
      {
        text = ''
          [Desktop Entry]
          Type=Application
          Version=1.0
          Name=Vencord
          Comment=Vencord autostart script
          Exec=sh -c "${lib.getExe pkgs.vesktop} --start-minimized"
          Terminal=false
          StartupNotify=false
        '';
      };

  # Taken from
  # https://github.com/TechieOllie/NixOS_dotfiles/blob/199584b266824c0010535bf5c57db90105f3ed51/home/vesktop.nix#L77
  # and https://github.com/FryingGorilla/nixos-config/blob/564d0c74219b62d5b27e5e0882cdde2347bb622b/modules/home/karl/programs.nix#L355
  hm.systemd.user.services.vesktop = lib.mkIf (config.features.desktop.type == "umbriel") {
    Unit = {
      Description = "Vesktop in the system tray";
      # Explicitly follow the session target: otherwise its Wants= dependency
      # adds the opposite ordering and cycles through Noctalia's After=target.
      After = [
        "graphical-session.target"
        "noctalia.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # Noctalia's Type=simple service starts before its tray is ready.
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
      ExecStart = "${lib.getExe pkgs.vesktop} --start-minimized";
      RestartSec = 5;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

}
