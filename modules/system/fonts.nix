{
  config,
  lib,
  pkgs,
  ...
}:
# TODO https://codeberg.org/adamcstephens/apple-fonts.nix/src/branch/main
lib.utilMods.mkModule config "fonts" {
  fonts.enableDefaultPackages = true;
  fonts.fontconfig = {
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

  environment.systemPackages = with pkgs; [
    fontpreview
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    joypixels
    nerdfonts

    # Microsoft Fonts
    corefonts
    vistafonts
  ];
}