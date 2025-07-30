{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  xdg.mimeApps =
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
    lib.mkIf (myLib.utils.getUserVars "defaultBrowser" config == "brave") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  programs.brave.enable = true;
  programs.brave.dictionaries = with pkgs; [ hunspellDictsChromium.en_US ];
  programs.brave.nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
  programs.brave.commandLineArgs = [
    "--enable-force-dark"
  ];
}
