# This file (and the iso directory) holds configs that I use across all ISO generations, uses some functionality from the core directory
{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = with inputs;
    [
      home-manager.nixosModules.home-manager
      nur.nixosModules.nur
      ../core/filesystem.nix
      ../core/nix.nix
      ../core/packages.nix
      ../core/shell.nix
      ../core/ssh.nix
      ../core/gpg.nix
      ../core/age.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);
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

  # Make NixOS use the latest Linux Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
}
