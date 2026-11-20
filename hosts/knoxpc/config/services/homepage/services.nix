{
  config,
  lib,
  myLib,
  ...
}:
let
  arrApps = builtins.filter (name: config.services.${name}.enable) [
    "sonarr"
    "radarr"
    "lidarr"
    "prowlarr"
  ];
  mkArrWidget = name: fields: {
    inherit fields;
    key = "{{HOMEPAGE_FILE_${lib.toUpper name}_API_KEY}}";
  };
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
          url = "http://127.0.0.1:${port}";
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
  sops.secrets = lib.genAttrs (map (name: "${name}-api-key") arrApps) (
    _:
    myLib.secrets.mkSecretFile {
      source = "arrs.yaml";
      subDir = [
        "hosts"
        config.networking.hostName
      ];
      restartUnits = [ "homepage-dashboard.service" ];
    }
  );

  systemd.services.homepage-dashboard = {
    serviceConfig.LoadCredential = map (
      name: "${name}-api-key:${config.sops.secrets."${name}-api-key".path}"
    ) arrApps;
    environment = lib.listToAttrs (
      map (
        name: lib.nameValuePair "HOMEPAGE_FILE_${lib.toUpper name}_API_KEY" "%d/${name}-api-key"
      ) arrApps
    );
  };

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
      Arr = [
        {
          Prowlarr = mkService {
            name = "prowlarr";
            port = toString config.services.prowlarr.settings.server.port;
            url = "https://prowlarr.${config.localdns.domain}";
            widget = mkArrWidget "prowlarr" [
              "numberOfQueries"
              "numberOfGrabs"
              "numberOfFailQueries"
            ];
          };
        }
        {
          Lidarr = mkService {
            name = "lidarr";
            port = toString config.services.lidarr.settings.server.port;
            url = "https://lidarr.${config.localdns.domain}";
            widget = mkArrWidget "lidarr" [
              "artists"
              "wanted"
              "queued"
            ];
          };
        }
        {
          Radarr = mkService {
            name = "radarr";
            port = toString config.services.radarr.settings.server.port;
            url = "https://radarr.${config.localdns.domain}";
            widget = mkArrWidget "radarr" [
              "movies"
              "missing"
              "queued"
            ];
          };
        }
        {
          Sonarr = mkService {
            name = "sonarr";
            port = toString config.services.sonarr.settings.server.port;
            url = "https://sonarr.${config.localdns.domain}";
            widget = mkArrWidget "sonarr" [
              "series"
              "wanted"
              "queued"
            ];
          };
        }
      ];
    }
    {
      Services = [
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
          Seerr = mkService {
            name = "seerr";
            url = "https://seerr.${config.localdns.domain}";
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
