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
      port,
      widget ? null,
    }:
    let
      attrPath = lib.splitString "." serviceName;
      enable = lib.getAttrFromPath ([ "services" ] ++ attrPath ++ [ "enable" ]) config;
      #port = lib.getAttrFromPath ([ "services" ] ++ attrPath ++ [ "port" ]) config;
    in
    lib.mkIf (enable || forceUse) (
      {
        inherit icon;
        # TODO: Use a FQDN
        href = "http://192.168.1.120:${port}";
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
      widget = {
        inherit metric chart;
        type = "glances";
        url = "http://localhost:${port}";
        version = 4;
      };
    };
in
{
  # TODO Not working
  services.homepage-dashboard.services = [
    {
      "Glances" = [
        {
          Info = mkGlanceWidget {
            metric = "info";
          };
        }
        {
          "CPU Temp" = mkGlanceWidget {
            metric = "sensor:Package id 0";
            chart = true;
          };
        }
        {
          Processes = mkGlanceWidget {
            metric = "process";
          };
        }
        {
          Network = mkGlanceWidget {
            metric = "network:wlp2s0";
          };
        }
        {
          "Media Disk" = mkGlanceWidget {
            metric = "fs:/mnt/media";
          };
        }
        {
          "System Backups" = mkGlanceWidget {
            metric = "fs:/mnt/sysbackup";
          };
        }
      ];
    }
    {
      Services = [
        {
          Jellyfin = mkService {
            name = "jellyfin";
            port = "8096/web";
          };
        }
        {
          Immich = mkService {
            name = "immich";
            port = "2283";
          };
        }
        {
          "Home Assistant" = mkService {
            name = "home-assistant";
            port = "8123";
            forceUse = true;
          };
        }
        {
          "Syncthing" = mkService {
            name = "syncthing";
            port = "8384";
          };
        }
      ];
    }
  ];
}
