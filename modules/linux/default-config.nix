{
  outputs,
  inputs,
  pkgs,
  hostname,
  stateVersion,
  ...
}:
with outputs.lib; {
  imports = with inputs;
    [
      ./user-nixos-configs.nix
    ]
    ++ outputs.lib.umport {path = ./core;};

  system.stateVersion = mkDefault stateVersion;
  networking.hostName = mkDefault hostname;

  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    killall
    git
    git-crypt
    vim
    wget
    curl
    smartmontools
    openssl
    aha
    p7zip # For opening 7-zip files
    dmidecode # Get hardware information
    perl
    tree
    just
    pre-commit
  ];

  nix = {
    # Perform nix store optimisation weekly to maintain low disk usage
    optimise = {
      automatic = true;
      dates = ["weekly"]; # Optional; allows customizing optimisation schedule
    };

    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      # Delete generations that are more than 14 days old
      options = "--delete-older-than 14d";
    };
  };

  # Enable firmware updates on Linux
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"];
  };

  /*
  boot = {
    # Make NixOS use the latest Linux Kernel
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
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
  */
}
