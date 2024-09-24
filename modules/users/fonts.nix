{
  pkgs,
  outputs,
  config,
  ...
}:
# TODO https://codeberg.org/adamcstephens/apple-fonts.nix/src/branch/main
outputs.lib.mkDesktopModule config "fonts" {
  nixos = {
    fonts = {
      enableDefaultPackages = true;
      fontconfig = {
        enable = true;
        hinting = {
          style = "slight";
          autohint = true;
        };
        subpixel = {
          lcdfilter = "default";
          rgba = "rgb";
        };
      };
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fontpreview
    noto-fonts
    noto-fonts-cjk
    noto-fonts-color-emoji
    joypixels
    nerdfonts

    # Microsoft Fonts
    corefonts
    vistafonts
  ];
}
