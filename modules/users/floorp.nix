{
  config,
  pkgs,
  outputs,
  ...
}:
outputs.lib.mkDesktopModule config "floorp" {
  xdg.mimeApps = outputs.lib.mkIf (config.defaultBrowser == "floorp") rec {
    enable = true;
    defaultApplications = {
      "default-web-browser" = ["floorp.desktop"];
      "text/html" = ["floorp.desktop"];
      "x-scheme-handler/http" = ["floorp.desktop"];
      "x-scheme-handler/https" = ["floorp.desktop"];
      "x-scheme-handler/about" = ["floorp.desktop"];
      "x-scheme-handler/unknown" = ["floorp.desktop"];
      "application/xhtml+xml" = ["floorp.desktop"];
      "text/xml" = ["floorp.desktop"];
    };
    associations.added = defaultApplications;
  };

  home.packages = with pkgs; [floorp];
}
