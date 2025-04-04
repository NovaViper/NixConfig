{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable fancy git changelogs
  hm.programs.git-cliff = {
    enable = true;

    settings = {
      header = "Changelog";
      trim = true;
    };
  };
}
