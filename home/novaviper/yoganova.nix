{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./global
    ./features/theming
    ./features/desktop/kde
    ./features/games
    ./features/emacs
    ./features/productivity
    #./features/virt-manager
  ];

  ### Special Variables
  variables.useVR = false;
  variables.useKonsole = false;
  variables.machine.gpu = "intel";
  variables.desktop.useWayland = true;
  #variables.machine.motherboard = "intel";
  variables.machine.buildType = "laptop";
  #variables.machine.lowSpec = true;
  ###

  home.packages = with pkgs; [ keepassxc krita libsForQt5.tokodon ];

  programs.plasma = lib.mkIf (config.variables.desktop.environment == "kde") {
    configFile = {
      kcminputrc."Libinput.1739.52992.SYNACF00:00 06CB:CF00 Touchpad" = {
        TapToClick = true;
        TapDragLock = true;
      };
      kwinrc.Xwayland.Scale = 1.25;
    };
  };
}
