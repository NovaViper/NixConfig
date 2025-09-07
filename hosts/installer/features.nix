{ myLib, ... }:
{
  imports = myLib.utils.importFeatures [
    ### Hardware
    "hardware/bluetooth"
    "hardware/hard-accel"
    "hardware/yubikey"

    ### Desktop Environment
    "desktop/plasma6"
  ];
}
