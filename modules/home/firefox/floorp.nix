{
  config,
  lib,
  pkgs,
  name,
  ...
}:
lib.utilMods.mkModule config "floorp" {
  xdg.mimeApps = lib.mkIf (config.variables.defaultBrowser == "floorp") rec {
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

  programs.floorp.enable = true;

  programs.floorp.nativeMessagingHosts = with pkgs; [fx-cast-bridge];

  programs.floorp.profiles."${name}" = {
    extensions = import ./extensions.nix {inherit pkgs;};

    search = {
      force = true;
      default = "Ecosia";
      engines = import ./searchEngines.nix {inherit lib pkgs;};
    };
  };
}
