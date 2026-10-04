{
  config,
  lib,
  pkgs,
  ...
}:
{

  hm.wayland.windowManager.niri.settings.binds =
    let
      noctalia = args: {
        spawn = [
          "noctalia"
          "msg"
        ]
        ++ args;
      };

      noctaliaWithTitle = title: args: {
        _props.hotkey-overlay-title = title;
        spawn = [
          "noctalia"
          "msg"
        ]
        ++ args;
      };

      spawnWithTitle = title: command: {
        _props.hotkey-overlay-title = title;
        spawn = [ command ];
      };

      shell = command: {
        spawn-sh = command;
      };

      locked-shell = command: {
        allow-when-locked = true;
        spawn-sh = command;
      };

      workspaces = lib.mergeAttrsList (
        map (n: {
          "Mod+${toString n}".focus-workspace = n;
          "Mod+Ctrl+${toString n}".move-column-to-workspace = n;
        }) (lib.range 1 9)
      );
    in
    lib.mkMerge [
      workspaces
      {
        # "Mod+Shift+E".quit = { };
        "Mod+Shift+Slash".show-hotkey-overlay = { };
        "Mod+Shift+Q".close-window = { };
        "Ctrl+Alt+Delete" = noctalia [
          "panel-toggle"
          "session"
        ];
        # Launcher mapped to Mod key via keyd service
        "Mod+D" = noctalia [
          "panel-toggle"
          "launcher"
        ];
        "Mod+Space".spawn._args = [
          (lib.getExe pkgs.vicinae)
          "toggle"
        ];
        "Mod+V" = noctalia [
          "panel-toggle"
          "clipboard"
        ];
        "Mod+N" = noctalia [
          "panel-toggle"
          "control-center"
          "notifications"
        ];

        "Mod+S" = noctalia [
          "panel-toggle"
          "control-center"
        ];

        "Mod+Comma" = noctalia [
          "settings-toggle"
        ];

        "Alt+Tab" = noctalia [
          "window-switcher"
        ];

        # Lock
        "Mod+Alt+L" = {
          _props.hotkey-overlay-title = "Lock the Screen";
          spawn = [
            "session"
            "lock"
          ];
        };

        # Terminal
        "Mod+T" =
          spawnWithTitle "Open a Terminal: ${config.vars.apps.terminal.name}" config.vars.apps.terminal.name;

        # Audio
        XF86AudioRaiseVolume = noctalia [ "volume-up" ];
        XF86AudioLowerVolume = noctalia [ "volume-down" ];
        XF86AudioMute = noctalia [ "volume-mute" ];
        XF86AudioMicMute = noctalia [ "mic-mute" ];

        # Brightness
        XF86MonBrightnessUp = noctalia [ "brightness-up" ];
        XF86MonBrightnessDown = noctalia [ "brightness-down" ];
      }
    ];

}
