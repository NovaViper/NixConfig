# This file (and the global directory) holds config that I use on all hosts
{
  inputs,
  pkgs,
  config,
  self,
  ...
}: {
  imports = with inputs;
    [
      home-manager.nixosModules.home-manager
      nur.nixosModules.nur
      ./filesystem.nix
      ./fonts.nix
      ./locale.nix
      ./networking.nix
      ./nix.nix
      ./packages.nix
      ./security.nix
      ./shell.nix
      ./ssh.nix
      ./gpg.nix
      ./age.nix
      ./xdg.nix
      ./ld.nix
    ]
    ++ (builtins.attrValues self.nixosModules);

  # Add special args for home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs self;};
    backupFileExtension = ".bak";
  };

  # Config Nixpkgs
  nixpkgs = {
    overlays = builtins.attrValues self.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  boot = {
    # Make NixOS use the latest Linux Kernel
    kernelPackages = pkgs.linuxPackages_xanmod_latest;

    # Makes OBS Virtual Camera feature function
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
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

  # Enable firmware updates on Linux
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"];
  };

  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
}
