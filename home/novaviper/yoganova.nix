{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/theme
    ./features/desktop/kde/plasma6
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

  # Install a couple more packages
  home.packages = with pkgs; [ keepassxc krita kdePackages.tokodon ];

  # Make the display scaling larger because Hi-DPI screen
  programs.plasma.configFile.kwinrc.Xwayland.Scale.value = 1.25;
}
