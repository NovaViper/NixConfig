{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.xdg.mimeApps =
    let
      defaultApplications = {
        "mimetype" = "com.mitchellh.ghostty.desktop";
        "application/x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
        "x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
      };
    in
    lib.mkIf (myLib.utils.getUserVars "defaultTerminal" hm-config == "ghostty") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  hm.programs.ghostty.enable = true;

  hm.programs.ghostty.package = pkgs.inputs.ghostty.default;

  hm.programs.ghostty.installVimSyntax = true;

  hm.programs.ghostty.installBatSyntax = true;

  hm.programs.ghostty.settings = {
    cursor-click-to-move = true;
    mouse-hide-while-typing = true;
    desktop-notifications = true;

    shell-integration-features = false;

    cursor-style-blink = true;
    # Prompt on clipboard paste
    clipboard-paste-protection = true;
    # Show when a new update is out (since i'm using nightly)
    auto-update = "check";
  };
}
