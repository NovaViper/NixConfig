{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Pin all hosts to LTS Kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # Open terminal environment if we fail to boot
  boot.kernelParams = [ "boot.shell_on_fail" ];
  boot.loader = {
    systemd-boot.enable = true;
    #systemd-boot.editor = false; # We shouldn't be editing boot params imperatively
    systemd-boot.configurationLimit = 20;
    systemd-boot.memtest86.enable = true;

    efi.canTouchEfiVariables = true;
    #timeout = lib.mkForce 1; # If not working, get rid of state via `bootctl set-default && sudo bootctl set-timeout`
  };

  boot.loader.grub.enable = lib.mkForce false; # No need to break our system accidentally

  # More unstable, but good for reporting bugs. Disable if things break
  #systemd.enableStrictShellChecks = true;
}
