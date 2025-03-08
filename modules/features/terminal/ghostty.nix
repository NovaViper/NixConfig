{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkDesktopModule config "ghostty" {
  #modules.fonts.enable = true;

  hm.xdg.mimeApps = let
    defaultApplications = {
      "mimetype" = "com.mitchellh.ghostty.desktop";
      "application/x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
      "x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
    };
  in
    lib.mkIf (config.variables.defaultTerminal == "ghostty") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  hm.programs.ghostty.enable = true;

  hm.programs.ghostty.installVimSyntax = true;

  hm.programs.ghostty.settings = {
    cursor-click-to-move = true;
    mouse-hide-while-typing = true;
    desktop-notifications = true;
    shell-integration-features = true;
  };
}
