{ lib, ... }:
let
  workspaces = (map toString (lib.range 0 9))
    ++ (map (n: "F${toString n}") (lib.range 1 12));
  # Map keys to hyprland directions
  directions = rec {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
    h = left;
    l = right;
    k = up;
    j = down;
  };
  mod = "$mod";
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      # Move/resize windows with mod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bind = [
      "SUPERSHIFT,q,killactive"
      "SUPERSHIFT,e,exit"

      "${mod},s,togglesplit"
      "${mod},f,fullscreen,1"
      "SUPERSHIFT,f,fullscreen,0"
      "SUPERSHIFT,space,togglefloating"

      "${mod},minus,splitratio,-0.25"
      "SUPERSHIFT,minus,splitratio,-0.3333333"

      "${mod},equal,splitratio,0.25"
      "SUPERSHIFT,equal,splitratio,0.3333333"

      "${mod},g,togglegroup"
      "${mod},t,lockactivegroup,toggle"
      "${mod},apostrophe,changegroupactive,f"
      "SUPERSHIFT,apostrophe,changegroupactive,b"

      "${mod},u,togglespecialworkspace"
      "SUPERSHIFT,u,movetoworkspace,special"
    ] ++
      # Change workspace
      (map (n: "${mod},${n},workspace,name:${n}") workspaces) ++
      # Move window to workspace
      (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,name:${n}") workspaces) ++
      # Move focus
      (lib.mapAttrsToList
        (key: direction: "${mod},${key},movefocus,${direction}") directions) ++
      # Swap windows
      (lib.mapAttrsToList
        (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}")
        directions) ++
      # Move windows
      (lib.mapAttrsToList
        (key: direction: "SUPERCONTROL,${key},movewindoworgroup,${direction}")
        directions) ++
      # Move monitor focus
      (lib.mapAttrsToList
        (key: direction: "SUPERALT,${key},focusmonitor,${direction}")
        directions) ++
      # Move workspace to other monitor
      (lib.mapAttrsToList (key: direction:
        "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}")
        directions);
  };
}
