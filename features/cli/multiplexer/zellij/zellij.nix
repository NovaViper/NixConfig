{
  config,
  lib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
  cfg = hm-config.programs.zellij;
in
{
  hm.home.packages = with pkgs; [ chafa ];

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
    };
    # themes = ./themes.nix;
  };
}
