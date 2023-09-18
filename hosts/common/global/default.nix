# This file (and the global directory) holds config that i use on all hosts
{ inputs, outputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./zsh.nix
    ./locale.nix
    ./nix.nix
    ./filesystem.nix
    #./gpg.nix # TODO Look at this
    #./security.nix # TODO Add onto this
    #./optin-persistence.nix # TODO start on this
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  # Fix for qt6 plugins
  # TODO: maybe upstream this?
  /* environment.profileRelativeSessionVariables = {
       QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
     };
  */

  # Install all terminfo outputs
  environment.enableAllTerminfo = true;
  # Enable use of firmware that allows redistribution
  hardware.enableRedistributableFirmware = true;

  # A Fedora recommendation
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

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

  # Gets rid of mailddr bug until nixpkg update comes out https://github.com/NixOS/nixpkgs/issues/254807#issuecomment-1722351771
  boot.swraid.enable = false;

  # Enable firmware updates on Linux
  services.fwupd.enable = true;

  # Install more packages
  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    killall
    git-crypt
  ];
}
