{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = lib.singleton inputs.agenix.nixosModules.default;
  home-manager.sharedModules = lib.singleton inputs.agenix.homeManagerModules.default;

  environment.systemPackages = with pkgs; [agenix age age-plugin-yubikey];

  age.ageBin = "PATH=$PATH:" + lib.makeBinPath [pkgs.age-plugin-yubikey] + " " + lib.getExe pkgs.age;

  services.pcscd.enable = lib.mkForce true;
}
