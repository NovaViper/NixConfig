{ lib, ... }:
{
  stylix = {
    autoEnable = lib.mkForce false;
    enable = lib.mkForce false;
  };
  home-manager.sharedModules = lib.singleton {
    stylix = {
      autoEnable = lib.mkForce false;
      enable = lib.mkForce false;
    };
  };
}
