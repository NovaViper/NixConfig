{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./global.nix ./wayland.nix ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };
}
