# This file (and the global directory) holds config that I use on all hosts
{ inputs, outputs, pkgs, config, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./zsh.nix
    ./locale.nix
    ./nix.nix
    ./filesystem.nix
    ./openssh.nix
    ./gpg.nix
    ./network.nix
    #./sops.nix
    ./security.nix
    #./optin-persistence.nix # TODO Maybe later, alot more involved than initally thought
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  # Enable use of firmware that allows redistribution
  hardware.enableRedistributableFirmware = true;

  boot = {
    # A Fedora recommendation: https://fedoraproject.org/wiki/Changes/IncreaseVmMaxMapCount
    # Good for Windows games running through Wine or Steam
    kernel.sysctl."vm.max_map_count" = 2147483642;

    # Make NixOS use the latest Linux Kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Makes OBS Virtual Camera feature function
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  };

  console = {
    earlySetup = true;
    useXkbConfig = true;
    #packages = [];
  };

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  #systemd.services.NetworkManager-wait-online.enable = false;

  # Enable firmware updates on Linux
  services.fwupd.enable = true;

  # Install more packages
  environment = {
    systemPackages = with pkgs; [
      pciutils
      usbutils
      killall
      git-crypt
      smartmontools
      openssl
    ];

    # Fix for qt6 plugins
    # TODO: maybe upstream this?
    profileRelativeSessionVariables = {
      QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
    };
  };
}
