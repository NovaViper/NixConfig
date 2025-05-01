{
  lib,
  pkgs,
  username,
  ...
}:
{
  features.vr = "alvr";

  # Actually enable the program
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  # Fixes issue with SteamVR not starting
  system.activationScripts.fixSteamVR = "${lib.getExe' pkgs.libcap "setcap"} CAP_SYS_NICE+ep /home/${username}/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
}
