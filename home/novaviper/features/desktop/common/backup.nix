{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  utils = import ../../../../lib/utils.nix {inherit config pkgs;};
in {
  home.packages = with pkgs; [vorta];

  sops.secrets."borg_token" = {
    format = "binary";
    sopsFile = utils.refDots "secrets/borg/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
    path = "${config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
  };
}
