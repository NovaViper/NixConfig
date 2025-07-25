{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.daemon.settings = {
    data-root = "/var/lib/containers";
  };

  virtualisation.docker.rootless.enable = true;
}
