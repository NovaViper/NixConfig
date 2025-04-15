{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  xdg.mimeApps = let
    defaultApplications = {
      "mimetype" = "konsole.desktop";
      "application/x-terminal-emulator" = "konsole.desktop";
      "x-terminal-emulator" = "konsole.desktop";
    };
  in
    lib.mkIf (myLib.utils.getUserVars "defaultTerminal" config == "konsole") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  # DefaultThemed profile is considered the Stylix module
  programs.konsole.enable = true;
}
