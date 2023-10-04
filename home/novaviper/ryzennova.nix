{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/desktop/kde
    ./features/games
    ./features/emacs
    ./features/productivity
    ./features/virt-manager
    #./features/vnc TODO: Work on remote desktop
  ];

  colorscheme = inputs.nix-colors.colorSchemes.dracula;

  home.packages = with pkgs; [ keepassxc krita libsForQt5.tokodon ];
}
