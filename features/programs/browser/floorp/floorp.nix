{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.xdg.mimeApps =
    let
      defaultApplications = {
        "default-web-browser" = [ "floorp.desktop" ];
        "text/html" = [ "floorp.desktop" ];
        "x-scheme-handler/http" = [ "floorp.desktop" ];
        "x-scheme-handler/https" = [ "floorp.desktop" ];
        "x-scheme-handler/about" = [ "floorp.desktop" ];
        "x-scheme-handler/unknown" = [ "floorp.desktop" ];
        "application/xhtml+xml" = [ "floorp.desktop" ];
        "text/xml" = [ "floorp.desktop" ];
      };
    in
    lib.mkIf (myLib.utils.getUserVars "defaultBrowser" hm-config == "floorp") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  hm.programs.floorp.enable = true;

  hm.programs.floorp.nativeMessagingHosts = with pkgs; [
    fx-cast-bridge
    kdePackages.plasma-browser-integration
  ];

  hm.programs.floorp.profiles."${hm-config.home.username}" = {
    search = {
      force = true;
      default = "ecosia";
    };
  };
}
