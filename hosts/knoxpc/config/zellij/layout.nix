{
  config,
  lib,
  pkgs,
  ...
}:
let
  statusbarTemplate = builtins.readFile ./statusbar.kdl;
in
{
  hm.home.packages = with pkgs.my-scripts; [
    status-cpu-ram
  ];

  hm.programs.zellij.layouts = {
    default =
      # kdl
      ''
        layout {
          ${statusbarTemplate}
          default_tab_template {
              children
              statusbar size=1
          }
          pane
          statusbar size=1
        }
      '';
  };
}
