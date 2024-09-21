{
  outputs,
  inputs,
  config,
  pkgs,
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
    stylix = {
      enable = true;
      system-wide = true;
      configs = {
        base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
        override = {
          scheme = "BetterDracula";
          base00 = "282a36";
          base01 = "363447";
          base02 = "44475a";
          base03 = "6272a4";
          base04 = "9ea8c7";
          base05 = "f8f8f2";
          base06 = "f0f1f4";
          base07 = "ffffff";
          base08 = "ff5555";
          base09 = "ffb86c";
          base0A = "f1fa8c";
          base0B = "50fa7b";
          base0C = "8be9fd";
          base0D = "80bfff";
          base0E = "ff79c6";
          base0F = "bd93f9";
        };
        polarity = "dark";
        cursor = {
          package = pkgs.capitaine-cursors;
          name = "capitaine-cursors-white";
          size = 24;
        };
        fonts = rec {
          sansSerif = {
            package = pkgs.nerdfonts;
            name = "NotoSans Nerd Font";
          };
          serif = sansSerif;
          monospace = {
            package = pkgs.nerdfonts;
            name = "0xProto Nerd Font Mono";
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
        opacity = {
          applications = 1.0;
          desktop = 1.0;
          popups = 1.0;
          terminal = 1.0;
        };
      };
    };
  };

  stylix.targets = outputs.lib.mkForce {
    # Enable 256 colors for kitty
    kitty.variant256Colors = true;
    # Causes some mismatched colors with Dracula-tmux theme
    tmux.enable = false;
    # Disable stylix's KDE module, very broken currently
    kde.enable = false;
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
