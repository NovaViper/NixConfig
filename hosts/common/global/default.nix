# This file (and the global directory) holds config that i use on all hosts
{ inputs, outputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./zsh.nix
    ./locale.nix
    ./nix.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  hardware.enableRedistributableFirmware = true;

  # Fix for qt6 plugins
  # TODO: maybe upstream this?
  /* environment.profileRelativeSessionVariables = {
       QT_PLUGIN_PATH = [ "/lib/qt-6/plugins" ];
     };

     environment.enableAllTerminfo = true;

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
