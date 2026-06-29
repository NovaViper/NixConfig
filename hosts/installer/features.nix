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
}
