{
  config,
  lib,
  ...
}:
let
  mkService =
    {
      name,
      serviceName ? name,
      forceUse ? false,
      icon ? "${name}.svg",
      port ? toString (
        let
          service = lib.getAttrFromPath ([ "services" ] ++ lib.splitString "." serviceName) config;
        in
        if service ? port then
          service.port
        else if service ? guiAddress then
          lib.last (lib.splitString ":" service.guiAddress)
        else
          throw "mkService: ${serviceName} needs an explicit port"
      ),
      url ? "http://${config.localdns.address}:${port}",
      widget ? null,
    }:
    let
      attrPath = lib.splitString "." serviceName;
      enable = lib.getAttrFromPath ([ "services" ] ++ attrPath ++ [ "enable" ]) config;
    in
    lib.mkIf (enable || forceUse) (
      {
        inherit icon;
        href = url;
      }
      // lib.optionalAttrs (widget != null) {
        widget = widget // {
          type = name;
          url = "http://localhost:${port}";
        };
      }
    );
  mkGlanceWidget =
    {
      metric,
      chart ? false,
    }:
    let
      port = toString config.services.glances.port;
    in
    {
      href = "https://glances.home.arpa";
      widget = {
        inherit metric chart;
        type = "glances";
        url = "http://localhost:${port}";
        version = 4;
      };
    };
in
{
  services.homepage-dashboard.services = [
    {
      "Glances" = [
        {
          "CPU Temp" = mkGlanceWidget {
            metric = "sensor:Package id 0";
            chart = true;
          };
        }
      ];
    }
    {
      Services = [
        {
          Prowlarr = mkService {
            name = "prowlarr";
            port = toString config.services.prowlarr.settings.server.port;
            url = "https://prowlarr.${config.localdns.domain}";
          };
        }
        {
          Lidarr = mkService {
            name = "lidarr";
            port = toString config.services.lidarr.settings.server.port;
            url = "https://lidarr.${config.localdns.domain}";
          };
        }
        {
          Radarr = mkService {
            name = "radarr";
            port = toString config.services.radarr.settings.server.port;
            url = "https://radarr.${config.localdns.domain}";
          };
        }
        {
          Sonarr = mkService {
            name = "sonarr";
            port = toString config.services.sonarr.settings.server.port;
            url = "https://sonarr.${config.localdns.domain}";
          };
        }
        {
          qBittorrent = mkService {
            name = "qbittorrent";
            url = "https://qbittorrent.${config.localdns.domain}";
          };
        }
        {
          Jellyfin = mkService {
            name = "jellyfin";
            port = "8096/web";
            url = "https://jellyfin.home.arpa";
          };
        }
        {
          Immich = mkService {
            name = "immich";
            url = "https://immich.home.arpa";
          };
        }
        {
          "Home Assistant" = mkService {
            name = "home-assistant";
            port = "8123";
            url = "https://smarthome.home.arpa";
            forceUse = true;
          };
        }
        {
          "Syncthing" = mkService {
            name = "syncthing";
            url = "https://syncthing.${config.localdns.domain}";
          };
        }
      ];
    }
  ]
  ++ lib.optional config.networking.wormhole.enable {
    Network = [
      {
        Wormhole = {
          icon = "wireguard.svg";
          description = "Terminus tunnel";
          ping = "10.9.0.1";
        };
      }
    ];
  };
}
