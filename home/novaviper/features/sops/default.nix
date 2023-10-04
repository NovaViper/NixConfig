{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    gnupg = {
      home = "${config.home.homeDirectory}/.gnupg";
      sshKeyPaths = [ ];
    };
  };
}
