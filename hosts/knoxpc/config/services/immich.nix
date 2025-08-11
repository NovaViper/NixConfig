{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}:
let
  user = primaryUser;
  group = base.group;
  base = config.users.users.${user};
  uid = base.uid;
  gid = config.users.groups.${user}.gid;
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
    mediaLocation = "/mnt/media/Photos";
    openFirewall = true;
    environment = {
      IMMICH_TRUSTED_PROXIES = "100.86.0.0/10,192.168.1.0/24";
    };
  };

  # TODO Setup for later
  # services.immich-public-proxy = {
  #   enable = true;
  #   immichUrl = "http://localhost:3001";
  #   port = 3001;
  #   openFirewall = true;
  # };

  # May not use this
  #   virtualisation.oci-containers.containers = {
  #   immich = {
  #
  #       image = "ghcr.io/immich-app/immich-server:release";
  #       autoStart = true;
  #       ports = ["8080:8082"];
  #       volumes = [
  #         "immich:/config"
  #         "/mnt/media/Photos:/photos"
  #         "/etc/localtime:/etc/localtime:ro"
  #       ];
  # #devices = ["/dev/dri"];
  #       environment = {
  #         TZ = "America/Chicago";
  #         PUID = toString uid;
  #         PGID = toString gid;
  #       };
  #   };
  #   };

}
