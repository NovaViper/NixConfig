{ myLib, ... }:
{
  imports = myLib.utils.importFeatures "system" [
    ### Hardware
    "hardware/yubikey"

    ### Service
    "services/tailscale"

    ### Locale
    "lang/us-english"

    ### Theme
    #"theme/dracula"
    #"theme/catppuccin"

    ### Boot
    "boot/pretty-boot"
    "boot/disko"
  ];
}
