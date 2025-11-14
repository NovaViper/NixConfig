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
    # Enable the ability to move the cursor at prompts by using alt+click
    cursor-click-to-move = true;
    # Make the mouse disappear when typing
    mouse-hide-while-typing = true;
    # I want notifications
    desktop-notifications = true;
    # Enable shell integration
    shell-integration-features = "no-cursor,sudo,title";
    # Enable terminal bell
    bell-features = "system";
    # Enable link previews
    link-previews = true;
    # Make cursor blink
    cursor-style-blink = true;
    # Prompt on clipboard paste
    clipboard-paste-protection = true;
    # Automatically copy selected text to the clipboard
    copy-on-select = true;
    # Show when a new update is out (since I'm using nightly)
    auto-update = "check";

    keybind = [
      "global:ctrl+shift+t=toggle_quick_terminal"
    ];
  };
}
