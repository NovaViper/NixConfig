{ myLib, ... }:
{
  imports = myLib.utils.importFeatures [
    ### Hardware
    "hardware/qmk"
    "hardware/rgb"

    ### Service
    "services/sunshine-server"
    "services/wivrn"

    ### Applications
    "apps/libvirt"
    "apps/obs"
  ];

  features.includeMinecraftServer = true;
}
