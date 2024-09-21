{
  outputs,
  config,
  pkgs,
  ...
}:
outputs.lib.mkDesktopModule config "konsole" {
  modules.fonts.enable = true;

  xdg.mimeApps = outputs.lib.mkIf (config.defaultTerminal == "konsole") rec {
    defaultApplications = {
      "mimetype" = "konsole.desktop";
      "application/x-terminal-emulator" = "konsole.desktop";
      "x-terminal-emulator" = "konsole.desktop";
    };
    associations.added = defaultApplications;
  };

  # DefaultThemed profile is considered the Stylix module
  programs.konsole.enable = true;
}
