{ config, pkgs, ... }:
{
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
}
