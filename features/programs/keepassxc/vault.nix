_: {
  hm.programs.keepassxc.enable = true;
  hm.programs.keepassxc.autostart = true;
  hm.programs.keepassxc.settings = {
    Browser.Enabled = true;

    GUI = {
      ApplicationTheme = "classic";
      MinimizeOnClose = true;
      MinimizeOnStartup = true;
      ShowTrayIcon = true;
    };

    Security = {
      LockDatabaseIdle = true;
      LockDatabaseIdleSeconds = 600;
    };
  };
}
