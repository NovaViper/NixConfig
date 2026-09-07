{ myLib, lib, ... }:
{
  imports = myLib.utils.importFeatures {
    desktop = lib.singleton "plasma6";
    hardware = [
      "bluetooth"
      "hard-accel"
      "yubikey"
    ];
  };

  vars.desktop.profile = "minimal";

  vars.host = {
    configDirectory = "/etc/nixos";
    scalingFactor = 1;
  };

  # Enable Nvidia drivers for the ISO
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;

  # Disabling these makes the ISO boot
  programs.nix-ld.enable = lib.mkForce false;

  hm.programs.plasma =
    let
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        #splashScreen = "";
      };
    in
    {
      overrideConfig = true;
      inherit workspace;
    };
}
