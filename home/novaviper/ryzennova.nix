{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/desktop/kde
    ./features/games
    ./features/emacs
    ./features/productivity
    ./features/virt-manager
  ];

  ### Special Variables
  variables.useKonsole = false;
  variables.machine.gpu = "nvidia";
  ###

  home.packages = with pkgs; [ keepassxc krita libsForQt5.tokodon ];
}
