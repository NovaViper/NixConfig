{ config, ... }:
{
  hm.programs.keepassxc.enable = true;
  hm.programs.keepassxc.autostart = true;

  # Quick Unlock uses system polkit even though Home Manager installs the app.
  environment.etc."polkit-1/actions/org.keepassxc.KeePassXC.policy".source =
    "${config.hm.programs.keepassxc.package}/share/polkit-1/actions/org.keepassxc.KeePassXC.policy";
  systemd.services.polkit.reloadTriggers = [
    config.environment.etc."polkit-1/actions/org.keepassxc.KeePassXC.policy".source
  ];
  # hm.programs.keepassxc.settings = {
  #   Browser.Enabled = true;
  #
  #   GUI = {
  #     ApplicationTheme = "classic";
  #     MinimizeOnClose = true;
  #     MinimizeOnStartup = true;
  #     ShowTrayIcon = true;
  #   };
  #
  #   Security = {
  #     LockDatabaseIdle = true;
  #     LockDatabaseIdleSeconds = 600;
  #   };
  # };
}
