# This file (and the global directory) holds config that I use on all hosts
{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}: {
  imports = with inputs;
    [
      home-manager.nixosModules.home-manager
      stylix.nixosModules.stylix
      ./filesystem.nix
      ./fonts.nix
      ./locale.nix
      ./networking.nix
      ./nix.nix
      ./packages.nix
      ./security.nix
      ./shell.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  # Stylix configuration
  # For Home-Manager standalone
  stylix.homeManagerIntegration.autoImport = false;

  # Add special args for home-manager
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = ".bak";
  };

  # Config Nixpkgs
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  boot = {
    # Make NixOS use the latest Linux Kernel
    kernelPackages = pkgs.linuxPackages_latest;

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
  services.fwupd.enable = true;
}
