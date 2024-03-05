{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/theming
    ./features/desktop/kde/plasma5
    ./features/games
    ./features/emacs
    ./features/productivity
    #./features/virt-manager
  ];

  ### Special Variables
  variables.useVR = false;
  variables.useKonsole = false;
  variables.machine.gpu = "intel";
  variables.desktop.displayManager = "wayland";
  #variables.machine.motherboard = "intel";
  variables.machine.buildType = "laptop";
  #variables.machine.lowSpec = true;
  ###

  home.packages = with pkgs; [ keepassxc krita libsForQt5.tokodon ];

  programs.plasma.configFile.kwinrc.Xwayland.Scale = 1.25;
}
