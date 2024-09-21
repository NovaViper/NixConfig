{
  outputs,
  pkgs,
  ...
}: {
  wallpaper = "${pkgs.kdePackages.breeze}/share/wallpapers/Next/contents/images/1920x1200.png";

  modules.fonts.enable = outputs.lib.mkForce false;

  theme.stylix = {
    enable = true;
    system-wide = true;
    configs = {
      polarity = "dark";
      cursor = {
        name = "breeze_cursors";
        size = 32;
      };
      fonts = rec {
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = sansSerif;
        monospace = {
          package = pkgs.hack-font;
          name = "Hack";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 10;
          desktop = 10;
          popups = 10;
          terminal = 11;
        };
      };
    };
  };

  programs.plasma.workspace.lookAndFeel = "org.kde.breezedark.desktop";
}
