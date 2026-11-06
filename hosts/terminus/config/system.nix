{ lib, ... }:
{
  # The VPS should use UTC time, not local time, to avoid issues with daylight savings time
  time.hardwareClockInLocalTime = lib.mkForce false;

  # We don't need fwupd on a VPS, and it can cause issues with the Oracle Cloud hypervisor
  services.fwupd.enable = lib.mkForce false;

  fonts.enableDefaultPackages = lib.mkForce false;
  fonts.packages = lib.mkForce [ ];
  fonts.fontconfig.enable = lib.mkForce false;

  # Limit concurrent builds on the 2 OCPU / 6 GiB instance.
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
  # Limit the size of the systemd journal to avoid filling up the disk
  services.journald.settings.Journal = {
    SystemMaxUse = "256M";
    RuntimeMaxUse = "64M";
  };
}
