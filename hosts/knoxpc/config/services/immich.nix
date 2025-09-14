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
}
