{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  xdg.mimeApps = let
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
  in
    lib.mkIf (myLib.utils.getUserVars "defaultBrowser" config == "floorp") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  programs.floorp.enable = true;

  programs.floorp.nativeMessagingHosts = with pkgs; [fx-cast-bridge kdePackages.plasma-browser-integration];

  programs.floorp.profiles."${config.home.username}" = {
    search = {
      force = true;
      default = "ecosia";
    };
  };
}
