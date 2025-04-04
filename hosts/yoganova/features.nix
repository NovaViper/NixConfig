{myLib, ...}: {
  imports = myLib.utils.importFeatures "features" [
    ### Hardware
    "hardware/bluetooth"
    "hardware/hard-accel"
    #"hardware/howdy"
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
    #"apps/android-vm"

    ### Locale
    "lang/us-english"

    ### Boot
    "services/pretty-boot"
  ];
}
