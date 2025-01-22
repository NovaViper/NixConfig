{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkDesktopModule config "borg" {
  home.packages = with pkgs; [borgbackup vorta];

  hm.systemd.user.services.vorta = {
    Unit.Description = "Vorta";
    Install.WantedBy = ["default.target"];
    Service = {
      ExecStart = "${lib.getExe pkgs.vorta} --daemonise";
      Restart = "on-failure";
    };
  };
}
