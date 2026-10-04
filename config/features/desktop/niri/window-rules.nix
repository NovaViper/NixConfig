{
  config,
  lib,
  pkgs,
  ...
}:
{

  hm.wayland.windowManager.niri.settings.window-rule._children = [
    # {
    #   open-maximized = true;
    #   # Rounded corners for a modern look.
    #   geometry-corner-radius = 20;
    #   # Clips window contents to the rounded corner boundaries.
    #   clip-to-geometry = true;
    # }
    # Floating Noctalia settings window
    {
      match._props.app-id = "dev.noctalia.Noctalia";
      open-floating = true;
      default-column-width.fixed = 1080;
      default-window-height.fixed = 920;
    }
    {
      # https://github.com/niri-wm/niri/wiki/Application-Issues#steam
      match._props = {
        app-id = "steam";
        title = "^notificationtoasts_\d+_desktop$";
      };
      open-focused = false;
      default-floating-position._props = {
        x = 10;
        y = 10;
        relative-to = "bottom-right";
      };
    }
    # Block out password managers from screen capture
    # {}
  ];
}
