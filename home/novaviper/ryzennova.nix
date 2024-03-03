{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/theming
    ./features/desktop/kde
    ./features/games
    ./features/emacs
    ./features/productivity
    ./features/virt-manager
  ];

  ### Special Variables
  variables.useVR = true;
  variables.useKonsole = false;
  variables.machine.gpu = "nvidia";
  variables.desktop.displayManager = "x11";
  #variables.machine.motherboard = "amd";
  variables.machine.buildType = "desktop";
  #variables.machine.lowSpec = false;
  ###

  home.packages = with pkgs; [ keepassxc krita libsForQt5.tokodon ];
}
