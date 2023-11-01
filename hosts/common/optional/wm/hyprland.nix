{ config, lib, pkgs, inputs, ... }:
let nvidia = if config.variables.machine.gpu == "nvidia" then true else false;

in {
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    enableNvidiaPatches = nvidia;
  };
}
