{inputs, ...}: {
  imports = with inputs; [
    ### Hardware Modules
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-nvidia-nonprime
    hardware.nixosModules.common-pc-ssd
  ];
}
