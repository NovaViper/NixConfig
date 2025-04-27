{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.sharedModules = lib.singleton {
    stylix.targets = lib.mkForce {
      # Enable 256 colors for kitty
      kitty.variant256Colors = true;
      # Causes some mismatched colors with Dracula-tmux theme
      tmux.enable = false;
      # Disable stylix's KDE module, very broken currently
      kde.enable = false;
      # Using the doom-emacs theme
      emacs.enable = false;
    };

    home.packages = with pkgs; [
      dracula-theme
      (papirus-icon-theme.override {
        color = "violet";
      })
    ];

    programs = {
      plasma = let
        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
          iconTheme = "Papirus-Dark";
          colorScheme = "DraculaPurple";
          #splashScreen = "";
          wallpaperSlideShow = {
            path = ["${inputs.wallpapers}/"];
            interval = 300;
          };
        };
      in {
        overrideConfig = true;
        inherit workspace;
        kscreenlocker.appearance.wallpaperSlideShow = workspace.wallpaperSlideShow;
      };
      cava.settings.color = {
        gradient = 1;
        gradient_count = 8;
        gradient_color_1 = "'#8BE9FD'";
        gradient_color_2 = "'#9AEDFE'";
        gradient_color_3 = "'#CAA9FA'";
        gradient_color_4 = "'#BD93F9'";
        gradient_color_5 = "'#FF92D0'";
        gradient_color_6 = "'#FF79C6'";
        gradient_color_7 = "'#FF6E67'";
        gradient_color_8 = "'#FF5555'";
      };
    };
  };
}
