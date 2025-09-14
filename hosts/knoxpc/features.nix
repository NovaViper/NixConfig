{ myLib, ... }:
{
  imports = myLib.utils.importFeatures [
    ### Hardware
    "hardware/bluetooth"
    "hardware/yubikey"

    ### Service
    "services/tailscale"

    ### Theme
    #"theme/dracula"
    #"theme/catppuccin"

    ### Boot
    "boot/pretty-boot"
    "boot/disko"
  ];
}
