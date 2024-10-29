{
  config,
  lib,
  pkgs,
  ...
}:
lib.utilMods.mkModule config "konsole" {
  xdg.mimeApps = lib.mkIf (config.variables.defaultTerminal == "konsole") rec {
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
