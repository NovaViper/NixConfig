{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [borgbackup vorta];

  systemd.user.services.vorta = {
    Unit.Description = "Vorta";
    Install.WantedBy = ["default.target"];
    Service = {
      ExecStart = "${lib.getExe pkgs.vorta} --daemonise";
      Restart = "on-failure";
    };
  };
}
