{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  utils = import ../../../../lib/utils.nix {inherit config pkgs;};
in {
  home.packages = with pkgs; [borgbackup vorta];

  systemd.user.services = {
    vorta = {
      Unit = {
        Description = "Vorta";
      };
      Service = {
        ExecStart = "${pkgs.vorta}/bin/vorta --daemonise";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };

  sops.secrets."borg_token" = {
    format = "binary";
    sopsFile = utils.refDots "secrets/borg/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
    path = "${config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
  };
}
