{ config, lib, pkgs, inputs, ... }:
let nvidia = if config.variables.machine.gpu == "nvidia" then true else false;
in {
  imports = [ ./global.nix ./wayland.nix ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    enableNvidiaPatches = nvidia;
    xwayland.enable = true;
  };
}
