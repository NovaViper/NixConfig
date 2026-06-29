{
  config,
  lib,
  pkgs,
  ...
}:
{
  hm.home.packages = with pkgs; [
    borgbackup
    vorta
  ];

  hm.systemd.user.services.vorta = {
    Unit = {
      Description = "Vorta";
      After = [ "graphical-session.target" ];
    };

    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      ExecStart = "${lib.getExe pkgs.vorta} --daemonise";
      Restart = "on-failure";
    };
  };
}
