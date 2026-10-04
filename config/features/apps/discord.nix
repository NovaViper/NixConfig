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

  # Taken from
  # https://github.com/TechieOllie/NixOS_dotfiles/blob/199584b266824c0010535bf5c57db90105f3ed51/home/vesktop.nix#L77
  # and https://github.com/FryingGorilla/nixos-config/blob/564d0c74219b62d5b27e5e0882cdde2347bb622b/modules/home/karl/programs.nix#L355
  hm.systemd.user.services.vesktop = lib.mkIf (config.features.desktop.type == "niri") {
    Unit = {
      Description = "Vesktop in the system tray";
      # noctalia.service ordering + the sleep below: the tray icon didn't
      # show up in Noctalia's bar when this unit only ordered after
      # graphical-session.target, since that races Vesktop's own SNI tray
      # registration against Noctalia actually initializing its tray host.
      # Confirmed via reading home-manager's own tray.target (a bare
      # `Requires=graphical-session-pre.target`, no real ordering wired
      # against any tray host, and none of home-manager's own real
      # tray-consumer modules get an actual guarantee from it either) that
      # there's no clean systemd-level readiness signal available here —
      # Noctalia is a plain Type=simple service (upstream, not ours to
      # add real dbus-ready signaling to), so "started" only means
      # "process forked," not "tray host initialized." After=noctalia.service
      # is best-effort ordering; the sleep is the part that actually closes
      # the race in practice, matching what worked when tested manually.
      After = [ "noctalia.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
      ExecStart = "${hm-config.programs.vesktop.package}/bin/vesktop";
      RestartSec = 5;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

}
