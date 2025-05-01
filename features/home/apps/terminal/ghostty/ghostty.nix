{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  xdg.mimeApps =
    let
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

  programs.ghostty.package = pkgs.inputs.ghostty.default;

  programs.ghostty.installVimSyntax = true;

  programs.ghostty.installBatSyntax = true;

  programs.ghostty.settings = {
    cursor-click-to-move = true;
    mouse-hide-while-typing = true;
    desktop-notifications = true;

    shell-integration-features = true;

    cursor-style-blink = true;
    # Prompt on clipboard paste
    clipboard-paste-protection = true;
    # Show when a new update is out (since i'm using nightly)
    auto-update = "check";
  };
}
