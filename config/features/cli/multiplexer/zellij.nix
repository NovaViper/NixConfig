{
  config,
  lib,
  pkgs,
  ...
}:
{
  hm.programs.zellij = {
    enable = true;
    # Use our custom integration override..
    overrideIntegration = true;
    overrides = {
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
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
  };
}
