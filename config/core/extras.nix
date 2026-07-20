{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      # Networking
      curl
      wget

      # Version control
      git

      # Crypto
      openssl

      # System utilities
      killall
      pciutils
      usbutils
      tree

      # Hardware diagnostics
      dmidecode
      smartmontools
    ]
    ++ lib.optionals (config.features.hardware.apple.enable) [
      libimobiledevice
      ifuse # optional, to mount using 'ifuse'
      gvfs
      usbmuxd
    ]

    ++ lib.optionals (config.features.development.enable) [
      git-crypt
      aha
      p7zip # For opening 7-zip files
      perl
      just
      pre-commit
    ];

  services.usbmuxd = {
    enable = config.features.hardware.apple.enable;
    package = pkgs.usbmuxd2;
  };
}
