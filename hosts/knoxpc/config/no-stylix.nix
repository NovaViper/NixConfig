{ lib, ... }:
{
  stylix = {
    autoEnable = lib.mkForce false;
    enable = lib.mkForce false;
  };
}
