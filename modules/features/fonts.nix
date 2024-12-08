{
  config,
  myLib,
  pkgs,
  ...
}:
# TODO https://codeberg.org/adamcstephens/apple-fonts.nix/src/branch/main
myLib.utilMods.mkModule config "fonts" {
  fonts.enableDefaultPackages = true;

  fonts.packages = with pkgs; [
    # Icon fonts
    material-symbols
    joypixels

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # nerd fonts
    nerd-fonts.symbols-only

    # Microsoft Fonts
    corefonts
    vistafonts
  ];

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
  ];
}
