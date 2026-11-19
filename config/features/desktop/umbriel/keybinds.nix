{
  config,
  lib,
  pkgs,
  ...
}:
let
  workspaceKeybinds = lib.mergeAttrsList (
    map (n: {
      "Mod+${toString n}" = "workspace-switch ${toString n}";
      "Mod+Shift+${toString n}" = "window-move-to-workspace ${toString n}";
      "Mod+Ctrl+${toString n}" = "window-move-to-workspace ${toString n}";
    }) (lib.range 1 9)
  );
  noctalia = command: "spawn noctalia msg ${command}";
  media = command: {
    action = noctalia command;
    allow_when_locked = true;
  };
in
{
  # Based on https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml
  hm.programs.umbriel.settings.keybinds = {
    # Default bindings and app-specific replacements

    # Applications and session
    "Mod+Return" = {
      action = "spawn ${config.vars.apps.terminal.name}";
      repeat = false;
    };
    "Mod" = noctalia "panel-toggle launcher";
    "Mod+D" = noctalia "panel-toggle launcher";
    "Mod+Space" = "spawn ${lib.getExe pkgs.vicinae} toggle";
    "Mod+Q" = {
      action = "window-close";
      repeat = false;
    };
    "Mod+Shift+Q" = "window-close";
    "Mod+Escape" = "session-quit";
    "Mod+Shift+Escape" = {
      action = "shortcuts-inhibit-toggle";
      allow_when_inhibited = true;
      repeat = false;
    };
    "Mod+Comma" = noctalia "settings-toggle";

    # Media, volume, and brightness — available while locked
    "XF86AudioRaiseVolume" = media "volume-up";
    "XF86AudioLowerVolume" = media "volume-down";
    "XF86AudioMute" = media "volume-mute";
    "XF86AudioMicMute" = media "mic-mute";
    "XF86AudioPlay" = media "media toggle";
    "XF86AudioNext" = media "media next";
    "XF86AudioPrev" = media "media previous";
    "XF86MonBrightnessUp" = media "brightness-up";
    "XF86MonBrightnessDown" = media "brightness-down";

    # Focus, movement, and shortcut help
    "Mod+Left" = "window-focus-left";
    "Mod+Down" = "window-focus-down";
    "Mod+Up" = "window-focus-up";
    "Mod+Right" = "window-focus-right";
    "Mod+H" = "window-focus-left";
    "Mod+J" = "window-focus-down";
    "Mod+K" = "window-focus-up";
    "Mod+L" = "window-focus-right";
    "Mod+Tab" = "window-focus-next";
    "Alt+Tab" = noctalia "window-switcher hold";
    "Alt+Shift+Tab" = noctalia "window-switcher hold reverse";
    "Mod+Slash" = "cheatsheet-toggle";
    "Mod+Ctrl+Slash" = noctalia "settings-open keybinds";
    "Mod+Shift+Left" = "column-move-left";
    "Mod+Shift+Down" = "window-move-down";
    "Mod+Shift+Up" = "window-move-up";
    "Mod+Shift+Right" = "column-move-right";

    # Window state and layout
    "Mod+T" = {
      action = "window-toggle-floating";
      repeat = false;
    };
    "Mod+P" = "window-toggle-pinned";
    "Mod+M" = "window-toggle-maximize";
    "Mod+F" = "window-toggle-fullscreen";
    "Mod+R" = "window-cycle-primary-extent";
    "Mod+Alt+Comma" = "window-consume-left";
    "Mod+Period" = "window-consume-right";
    "Mod+W" = {
      action = "column-toggle-tabbed";
      repeat = false;
    };
    "Mod+WheelUp" = "window-focus-left";
    "Mod+WheelDown" = "window-focus-right";
    "Mod+O" = "overview-toggle";

    # Additional stacking controls
    "Mod+Alt+Left" = "window-set-region left";
    "Mod+Alt+Right" = "window-set-region right";
    "Mod+Alt+Up" = "window-toggle-maximize";
    "Mod+Alt+Down" = "window-clear-region";

    # Noctalia panels and session controls
    "Ctrl+Alt+Delete" = noctalia "panel-toggle session";
    "Mod+Alt+L" = noctalia "session lock";
    "Mod+V" = noctalia "panel-toggle clipboard";
    "Mod+N" = noctalia "panel-toggle control-center notifications";
    "Mod+S" = noctalia "panel-toggle control-center";

    # Screenshots — Noctalia capture and annotation editor
    "Print" = noctalia "screenshot-region";
    "Mod+Shift+S" = noctalia "screenshot-region";
    "Alt+Print" = noctalia "screenshot-window";
    "Shift+Print" = noctalia "screenshot-fullscreen";
    "Ctrl+Print" = noctalia "screenshot-fullscreen all";

    # Display settings and color picker
    "Mod+Shift+D" = "spawn ${lib.getExe pkgs.wdisplays} --kanshi";
    "Mod+Shift+C" = {
      action = "spawn ${lib.getExe pkgs.hyprpicker} --autocopy --format=hex";
      repeat = false;
    };
  }
  // workspaceKeybinds;
}
