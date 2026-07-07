{
  config,
  lib,
  pkgs,
  ...
}:
{
  # TODO https://codeberg.org/adamcstephens/apple-fonts.nix/src/branch/main
  fonts.enableDefaultPackages = true;

  fonts.packages =
    with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # nerd fonts
      nerd-fonts.symbols-only
    ]
    ++ lib.optionals (config.features.desktop.type != null) [
      # Icon fonts
      material-symbols
      joypixels

      # Microsoft Fonts
      corefonts
      vista-fonts
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
