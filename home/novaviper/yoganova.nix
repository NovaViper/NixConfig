{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/desktop/kde
    ./features/games
    ./features/emacs
    ./features/productivity
    #./features/virt-manager
  ];

  ### Special Variables
  variables.useKonsole = false;
  ###

  home.packages = with pkgs; [ keepassxc krita libsForQt5.tokodon ];

  programs.plasma = lib.mkIf (config.variables.desktop.environment == "kde") {
    configFile = {
      kcminputrc."Libinput.1739.52992.SYNACF00:00 06CB:CF00 Touchpad" = {
        TapToClick = true;
        TapDragLock = true;
      };
      kxkbrc.Layout.Options = "caps:ctrl_modifier";
      kwinrc.Xwayland.Scale = 1.25;
    };
  };
}
