{
  config,
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
      ExecStart = "${pkgs.vorta}/bin/vorta --daemonise";
      Restart = "on-failure";
    };
  };
}
