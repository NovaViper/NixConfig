{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  zenBrowserPkg = inputs.zen-browser.packages."${pkgs.system}".default;

  updatedZenBrowser = zenBrowserPkg.overrideAttrs (oldAttrs: rec {
    version = "1.0.1-a.2";
    src = builtins.fetchTarball {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-generic.tar.bz2";
      #sha256 = "sha256:0f86xhl66sqci8pskd7mk26vs9wc58kgfi3ci608d097gp4piams";
      sha256 = "sha256:1ymrfq3dwj05zyq7z1xyghmn9mvw8nh8ysl1r78gawjayab9x4r5";
    };
  });
in
  outputs.lib.mkDesktopModule config "zen" {
    # modules.flatpak.enable = true;

    # nixos.services.flatpak.packages = [ "io.github.zen_browser.zen" ];

    xdg.mimeApps = outputs.lib.mkIf (config.defaultBrowser == "zen") rec {
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
