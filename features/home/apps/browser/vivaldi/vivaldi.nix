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
        "default-web-browser" = [ "vivaldi.desktop" ];
        "text/html" = [ "vivaldi.desktop" ];
        "x-scheme-handler/http" = [ "vivaldi.desktop" ];
        "x-scheme-handler/https" = [ "vivaldi.desktop" ];
        "x-scheme-handler/about" = [ "vivaldi.desktop" ];
        "x-scheme-handler/unknown" = [ "vivaldi.desktop" ];
        "application/xhtml+xml" = [ "vivaldi.desktop" ];
        "text/xml" = [ "vivaldi.desktop" ];
      };
    in
    lib.mkIf (myLib.utils.getUserVars "defaultBrowser" config == "vivaldi") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  programs.vivaldi.enable = true;
  programs.vivaldi.dictionaries = with pkgs; [ hunspellDictsChromium.en_US ];
}
