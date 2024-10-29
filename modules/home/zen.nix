{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  zenBrowserPkg = inputs.zen-browser.packages."${pkgs.system}".default;

  updatedZenBrowser = zenBrowserPkg.overrideAttrs (oldAttrs: rec {
    version = "1.0.1-a.12";
    src = builtins.fetchTarball {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-generic.tar.bz2";
      sha256 = "sha256:0qs92h0vvw6qdcnpb076qr3dxw6hjyzzznb98dfp224z628vjm1i";
    };
  });
in
  lib.utilMods.mkModule config "zen" {
    xdg.mimeApps = lib.mkIf (config.variables.defaultBrowser == "zen") rec {
      enable = true;
      defaultApplications = {
        "default-web-browser" = ["zen.desktop"];
        "text/html" = ["zen.desktop"];
        "x-scheme-handler/http" = ["zen.desktop"];
        "x-scheme-handler/https" = ["zen.desktop"];
        "x-scheme-handler/about" = ["zen.desktop"];
        "x-scheme-handler/unknown" = ["zen.desktop"];
        "application/xhtml+xml" = ["zen.desktop"];
        "text/xml" = ["zen.desktop"];
      };
      associations.added = defaultApplications;
    };

    # home.packages = [ inputs.zen-browser.packages."${pkgs.system}".default ];
    home.packages = [updatedZenBrowser];
  }
