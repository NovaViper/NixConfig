{ config, lib, pkgs, inputs, ... }:

let nvidia = if config.variables.machine.gpu == "nvidia" then true else false;

in {
  #imports = [ inputs.hyprland.homeManagerModules.default ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.inputs.hyprland.hyprland;
    enableNvidiaPatches = nvidia;
    settings = {
      bind = let terminal = config.home.sessionVariables.TERMINAL;
      in [ "SUPER,RETURN,exec,${terminal}" ];
    };
  };
}
