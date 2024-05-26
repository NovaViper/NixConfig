{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts = {
    fontconfig.enable = true;
    # Enable base fonts
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-color-emoji
      joypixels
      nerdfonts

      # Microsoft Fonts
      corefonts
      vistafonts
    ];
  };
}
