{ inputs, ... }:
{
  imports = with inputs; [
    ### Hardware Modules
    hardware.nixosModules.framework-13-7040-amd
    #hardware.nixosModules.common-cpu-amd
    #hardware.nixosModules.common-pc-ssd
  ];

  services.fprintd.enable = true;
}
