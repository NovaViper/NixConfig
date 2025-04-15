{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  xdg.mimeApps = let
    defaultApplications = {
      "mimetype" = "com.mitchellh.ghostty.desktop";
      "application/x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
      "x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
    };
  in
    lib.mkIf (myLib.utils.getUserVars "defaultTerminal" config == "ghostty") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  programs.ghostty.enable = true;

  programs.ghostty.installVimSyntax = true;

  programs.ghostty.settings = {
    cursor-click-to-move = true;
    mouse-hide-while-typing = true;
    desktop-notifications = true;
    shell-integration-features = true;
  };
}
