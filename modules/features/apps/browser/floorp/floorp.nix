{
  config,
  lib,
  pkgs,
  ...
}: {
  hm.xdg.mimeApps = let
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
    lib.mkIf (config.userVars.defaultBrowser == "floorp") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  hm.programs.floorp.enable = true;

  hm.programs.floorp.nativeMessagingHosts = with pkgs; [fx-cast-bridge kdePackages.plasma-browser-integration];

  hm.programs.floorp.profiles."${config.userVars.username}" = {
    extensions.packages = import ../utils/extensions.nix {inherit pkgs;};

    search = {
      force = true;
      default = "Ecosia";
      engines = import ../utils/searchEngines.nix {inherit lib pkgs;};
    };
  };
}
