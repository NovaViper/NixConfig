{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  updatedZenBrowser = pkgs.inputs.zen-browser.overrideAttrs (oldAttrs: rec {
    version = "1.0.1-a.13";
    src = builtins.fetchTarball {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-generic.tar.bz2";
      sha256 = "sha256:0hicb3d09q0kgkfn9blvcci93hmli9vv35wbiybl0zd5h28yca4k";
    };
  });
in
{
  xdg.mimeApps =
    let
      defaultApplications = {
        "default-web-browser" = [ "zen.desktop" ];
        "text/html" = [ "zen.desktop" ];
        "x-scheme-handler/http" = [ "zen.desktop" ];
        "x-scheme-handler/https" = [ "zen.desktop" ];
        "x-scheme-handler/about" = [ "zen.desktop" ];
        "x-scheme-handler/unknown" = [ "zen.desktop" ];
        "application/xhtml+xml" = [ "zen.desktop" ];
        "text/xml" = [ "zen.desktop" ];
      };
    in
    lib.mkIf (myLib.utils.getUserVars "defaultBrowser" config == "zen") {
      enable = true;
      inherit defaultApplications;
      associations.added = defaultApplications;
    };

  home.packages = [ updatedZenBrowser ];
}
