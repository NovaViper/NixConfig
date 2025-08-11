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
  systemd.tmpfiles.rules = [
    "d /mnt/media/Library 0755 ${user} ${group} - -"
  ];

  services.jellyfin = {
    enable = true;
    user = user;
    group = group;

    # For internal access
    openFirewall = true;
  };

  # virtualisation.oci-containers.containers = {
  #   jellyfin = {
  #     image = "jellyfin/jellyfin";
  #     autoStart = true;
  #     ports = [
  #       "8096:8096"
  #       "8920:8920"
  #       "7359:7359/udp"
  #     ];
  #     volumes = [
  #       "jellyfin:/config"
  #       "/mnt/media/Music:/data/media/music"
  #       "/mnt/media/Movies:/data/media/movies"
  #     ];
  #     environment = {
  #       TZ = "America/Chicago";
  #       PUID = toString uid;
  #       PGID = toString gid;
  #     };
  #   };
  # };
}
