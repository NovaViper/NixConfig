{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  cfg = hm-config.programs.zellij;
  statusbarTemplate = builtins.readFile ./statusbar.kdl;
in
{
  hm.home.packages =
    with pkgs;
    [
      chafa
      cbonsai

    ]
    ++ (with pkgs.my-scripts; [
      status-battery
      status-cpu-ram
      status-network
    ]);

  hm.programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      env = {
        TERM = "xterm-256color";
      };
      mouse_hover_effects = true;
      visual_bell = true;
      load_plugins = {
        compact-bar = {
          location = "zellij:compact-bar";
          tooltip = "F1";
        };
      };
    };
    # themes = ./themes.nix;
    plugins = with pkgs.zellijPlugins; [ zjstatus ];
    layouts = {
      default =
        # kdl
        ''
          layout {
            ${statusbarTemplate}
            default_tab_template {
                children
                statusbar size=1
            }
            pane split_direction="vertical" {
              pane size="60%" focus=true
                pane split_direction="horizontal" {
                pane
                pane {
                  command "${lib.getExe pkgs.cava}"
                }
              }
            }
            statusbar size=1
          }
        '';
    };
  };
}
