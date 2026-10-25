{ config, ... }:
{
  localdns.proxies = {
    homepage = config.services.homepage-dashboard.listenPort;
    glances = config.services.glances.port;
  };

  # Since we are using a reverse proxy, we don't need to open the ports to the
  # outside world (plus we want it to be lan only)
  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";

  services.glances = {
    enable = true;
    openFirewall = false;
    extraArgs = [
      "--webserver"
      "--bind"
      "127.0.0.1"
    ];
  };
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = false;
    allowedHosts = "homepage.home.arpa";
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
        datetime.format = {
          dateStyle = "short";
          timeStyle = "short";
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
