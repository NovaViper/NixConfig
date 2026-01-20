{ config, ... }:
let
  mkHosts = addresses: builtins.concatStringsSep "," (map (addr: "${addr}:8082") addresses);
in
{
  services.glances.enable = true;
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = mkHosts [
      "localhost"
      "127.0.0.1"
      "192.168.1.120"
      "${config.networking.hostName}"
    ];
    settings = {
      tile = "KnoxPC Homelab";
      language = "en-US";
      layout = [
        {
          Glances = {
            header = false;
            style = "row";
            columns = 4;
          };
        }
      ];
    };
    widgets = [
      {
        datetime = {
          format = {
            dateStyle = "short";
            timeStyle = "short";
          };
        };
      }
      {
        search = {
          provider = "brave";
          showSearchSuggestions = true;
        };
      }
    ];
  };
}
