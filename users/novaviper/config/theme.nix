{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  theme = {
    packages = with pkgs; [dracula-theme];
    name = "Dracula";
    nameSymbolic = "dracula";
    app.rio.name = config.theme.name;
    iconTheme = {
      package = pkgs.papirus-icon-theme.override {
        color = "violet";
      };
      name = "Papirus-Dark";
    };
  };

  programs = {
    plasma = rec {
      overrideConfig = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "DraculaPurple";
        #splashScreen = "";
        wallpaperSlideShow = {
          path = ["${inputs.wallpapers}/"];
          interval = 300;
        };
      };
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
}
