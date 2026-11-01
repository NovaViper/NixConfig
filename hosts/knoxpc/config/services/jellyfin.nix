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
in
{
  localdns.proxies.jellyfin = 8096;

  systemd.tmpfiles.rules = [
    "d /storage/media/Library 0755 ${user} ${group} - -"
  ];

  services.jellyfin = {
    enable = true;
    user = user;
    group = group;

    # For internal access
    openFirewall = true;
  };
}
