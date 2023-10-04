{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [ sops ];

  sops = {
    gnupg = {
      home = "/home/root/.gnupg";
      sshKeyPaths = [ ];
    };
  };
}
