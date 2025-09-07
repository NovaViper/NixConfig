{ myLib, ... }:
{
  imports = myLib.utils.importFeatures [
    ### Hardware
    "hardware/bluetooth"
    "hardware/hard-accel"
    "hardware/yubikey"

    ### Service
    "services/gps"
    "services/localsend"
    "services/packaging"
    "services/printing"
    "services/syncthing"
    "services/tailscale"

    ### Desktop Environment
    "desktop/plasma6"

    ### Applications
    "apps/backup"
    "apps/discord"
    "apps/games"
    "apps/music-player"
    #"apps/android-vm"

    ### Theme
    #"theme/dracula"
    "theme/catppuccin"

    ### Boot
    "boot/pretty-boot"
    "boot/disko"
  ];
}
