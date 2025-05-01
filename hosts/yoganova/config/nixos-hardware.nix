{ inputs, ... }:
{
  imports = with inputs; [
    ### Hardware Modules
    hardware.nixosModules.common-cpu-intel
    hardware.nixosModules.common-pc-laptop-ssd
    hardware.nixosModules.common-hidpi
  ];
}
