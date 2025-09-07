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
        "default-web-browser" = [ "brave-browser.desktop" ];
        "text/html" = [ "brave-browser.desktop" ];
        "x-scheme-handler/http" = [ "brave-browser.desktop" ];
        "x-scheme-handler/https" = [ "brave-browser.desktop" ];
        "x-scheme-handler/about" = [ "brave-browser.desktop" ];
        "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
        "application/xhtml+xml" = [ "brave-browser.desktop" ];
        "text/xml" = [ "brave-browser.desktop" ];
      };
    in
    lib.mkIf (myLib.utils.getUserVars "defaultBrowser" hm-config == "brave") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  hm.programs.brave.enable = true;
  hm.programs.brave.dictionaries = with pkgs; [ hunspellDictsChromium.en_US ];
  hm.programs.brave.nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
  hm.programs.brave.commandLineArgs = [
    "--enable-force-dark"
  ];
}
