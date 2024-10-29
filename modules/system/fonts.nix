{
  config,
  lib,
  pkgs,
  ...
}:
# TODO https://codeberg.org/adamcstephens/apple-fonts.nix/src/branch/main
lib.utilMods.mkModule config "fonts" {
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
  environment.systemPackages = with pkgs; [
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
