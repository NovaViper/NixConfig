{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "borg" {
  home.packages = with pkgs; [borgbackup vorta];

  systemd.user.services.vorta = {
    Unit.Description = "Vorta";
    Install.WantedBy = ["default.target"];
    Service = {
      ExecStart = "${pkgs.vorta}/bin/vorta --daemonise";
      Restart = "on-failure";
    };
  };
}
