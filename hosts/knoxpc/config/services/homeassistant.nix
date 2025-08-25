{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}:
let
  uid = config.users.users.${primaryUser}.uid;
  gid = config.users.groups.${primaryUser}.gid;
in
{
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.matter-server.enable = true;
  services.mosquitto = {
    enable = true;
    dataDir = "/mnt/docker/homeassistant/mosquitto";
  };

  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "homeassistant/home-assistant:stable";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "--network=host"
      ];
      volumes = [
        "/mnt/docker/homeassistant:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/run/dbus:ro"
      ];
      ports = [
        "8123:8123"
        #"8124:80"
      ];
      environment = {
        TZ = "America/Chicago";
        PUID = toString uid;
        PGID = toString gid;
      };
    };
  };
}
