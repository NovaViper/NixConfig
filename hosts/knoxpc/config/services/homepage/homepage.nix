_: {
  services.glances.enable = true;
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = "localhost:8082,127.0.0.1:8082,192.168.1.120:8082";
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
