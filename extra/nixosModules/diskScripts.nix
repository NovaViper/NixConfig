{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;

  mkDiskScriptOption =
    description:
    mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Script (bundled with its runtime tools) that ${description}, intended to be run from the installer environment via `nix run .#nixosConfigurations.<host>.config.disks-*`.";
    };
in
{
  # Based on https://github.com/Baitinq/nixos-config/blob/979313a290981f3c9f62fb5c6f180e87e331ac5f/hardware/pc/disks.nix
  # The host's disks.nix file will define the scripts to create, format, and mount the disks. This module will then expose those scripts as packages in the system environment, so they can be run from the installer environment.
  options = {
    disks-create = mkDiskScriptOption "partitions this host's disks";
    disks-format = mkDiskScriptOption "formats this host's partitions";
    disks-mount = mkDiskScriptOption "mounts this host's partitions under /mnt";
  };

  config.environment.systemPackages = builtins.filter (p: p != null) [
    config.disks-create
    config.disks-format
    config.disks-mount
  ];
}
