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
  ];
}
