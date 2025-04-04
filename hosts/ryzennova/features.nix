{myLib, ...}: {
  imports = myLib.utils.importFeatures "features" [
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
    "services/syncthing"
    "services/tailscale"
    "services/vr/wivrn"

    ### Desktop Environment
    "desktop/plasma6"

    ### Applications
    "apps/backup"
    "apps/discord"
    "apps/games"
    "apps/libvirt"
    "apps/obs"
    #"apps/android-vm"

    ### Locale
    "lang/us-english"

    ### Boot
    "services/pretty-boot"
  ];

  features.includeMinecraftServer = true;
}
