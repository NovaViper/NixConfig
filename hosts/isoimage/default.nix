{ pkgs, modulesPath, lib, config, outputs, inputs, ... }: {
  imports = [
    ../common/global
    ../common/optional/desktop/kde/plasma6.nix
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];

  ### Special Variables
  variables.desktop.displayManager = "wayland";
  # Make the ISO not have a custom theme
  theme = lib.mkForce { };

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia and other drivers for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" "modesetting" "fbdev" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
