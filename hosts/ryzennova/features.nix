{ myLib, ... }:
{
  imports = myLib.utils.importFeatures "system" [
    ### Hardware
    "hardware/bluetooth"
    "hardware/hard-accel"
    "hardware/qmk"
    "hardware/rgb"
    "hardware/yubikey"

    ### Service
    "services/gps"
    "services/localsend"
    "services/packaging"
    "services/printing"
    "services/sunshine-server"
    "services/tailscale"
    "services/vr/wivrn"

    ### Desktop Environment
    "desktop/plasma6"

    ### Applications
    "apps/games"
    "apps/libvirt"
    "apps/obs"
    #"apps/android-vm"

    ### Locale
    "lang/us-english"

    ### Theme
    "theme/dracula"

    ### Boot
    "boot/pretty-boot"
    "boot/disko"
  ];

  features.includeMinecraftServer = true;
}
