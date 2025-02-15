{
  config,
  lib,
  myLib,
  pkgs,
  username,
  ...
}:
myLib.utilMods.mkDesktopModule config "alvr" {
  # Make sure to enable the needed gaming and vr modules
  modules.gaming = {
    enable = true;
    vr.enable = true;
  };

  # Actually enable the program
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  # Fixes issue with SteamVR not starting
  system.activationScripts.fixSteamVR = "${lib.getExe' pkgs.libcap "setcap"} CAP_SYS_NICE+ep /home/${username}/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
}
