{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  uid = config.users.users.${username}.uid;
  gid = config.users.groups.${username}.gid;
in
{
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.matter-server.enable = true;
  services.mosquitto = {
    enable = true;
    dataDir = "/storage/services/homeassistant/mosquitto";
  };

  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "docker.io/homeassistant/home-assistant:stable";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "--network=host"
        # Needed for Bluetooth to work
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];
      volumes = [
        "/storage/services/homeassistant:/config"
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
