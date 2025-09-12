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
    "programs/libvirt"
    "programs/obs"
  ];

  features.includeMinecraftServer = true;
}
