{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  user = username;
  group = base.group;
  base = config.users.users.${user};
  uid = base.uid;
  gid = config.users.groups.${user}.gid;
  immichPath = "/mnt/media/Library/Photos/Immich";
in
{
  users.users.immich.extraGroups = [
    "samba"
    "video"
    "render"
  ];

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = immichPath;
    openFirewall = true;
    environment = {
      IMMICH_TRUSTED_PROXIES = "100.86.0.0/10,192.168.1.0/24";
    };
    machine-learning = {
      enable = true;
      environment = {
        #MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/immich/model-cache";
        MPLCONFIGDIR = "/var/cache/immich/matplotlib";
        #HF_TOKEN_PATH = "/var/cache/immich/huggingface/token";
        HF_XET_CACHE = "/var/cache/immich/huggingface/xet";
      };
    };
  };

  # TODO Setup for later
  # services.immich-public-proxy = {
  #   enable = true;
  #   immichUrl = "http://localhost:3001";
  #   port = 3001;
  #   openFirewall = true;
  # };

  # Taken from https://github.com/brumik/config/blob/6b928e7e706702f5396b7961da151150ac1cbe11/hosts/sleeper/homelab/immich.nix#L64

  systemd.tmpfiles.rules = [
    # Set up the dumping of the database #
    "d /var/lib/pgdump 0755 postgres postgres -"
    # Create path for immich
    "d ${immichPath} 0775 immich immich - -"
  ];

  # Create a service to backup the PG database
  systemd.services.pgDumpImmich = {
    description = "PostgreSQL dump of the immich database";
    after = [ "postgresql.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${lib.getExe' pkgs.postgresql "pg_dump"} -f /var/lib/pgdump/immich_dump.sql immich";
    };
  };

  # generate wrapper scripts, as described in the createWrapper option
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "restore-immich-pg" ''
      systemctl stop immich-server
      sudo -u postgres ${lib.getExe' pkgs.postgresql "dropdb"} --if-exists immich
      sudo -u postgres ${lib.getExe' pkgs.postgresql "createdb"} immich
      sudo -u postgres ${lib.getExe' pkgs.postgresql "psql"} -d immich -f /var/lib/pgdump/immich_dump.sql
      systemctl start immich-server
    '')
  ];
}
