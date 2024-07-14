{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  c = config.lib.stylix.colors.withHashtag;
  f = config.stylix.fonts;
in {
  stylix = {
    enable = true;
    autoEnable = true;
    targets = {
      # Enable 256 colors for kitty
      kitty.variant256Colors = true;
      # Causes some mismatched colors with Dracula-tmux theme
      tmux.enable = false;
      # Disable stylix's KDE module, very broken currently
      kde.enable = false;
    };
  };

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

  ##################### INDIVUAL APP CONFIGURATION
  # KDE + Yakuake Theming
  xdg = (mkIf config.variables.useKonsole) {
    dataFile = {
      "konsole/Stylix.colorscheme".source = config.lib.stylix.colors {
        template = builtins.readFile ./konsole.mustache;
        extension = ".colorscheme";
      };
      "yakuake/skins/Dracula".source = fetchGit {
        url = "https://github.com/dracula/yakuake";
        rev = "591a705898763167dd5aca2289d170f91a85aa56";
      };
    };
  };

  programs = {
    plasma = rec {
      overrideConfig = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "DraculaPurple";
        iconTheme = "${config.theme.iconTheme.name}";
        #splashScreen = "";
        cursor = {
          theme = "${config.stylix.cursor.name}";
          size = config.stylix.cursor.size;
        };
        wallpaperSlideShow = {
          path = ["${inputs.wallpapers}/"];
          interval = 300;
        };
      };
      kscreenlocker.wallpaperSlideShow = workspace.wallpaperSlideShow;
      fonts = rec {
        general = {
          family = "${f.sansSerif.name}";
          pointSize = f.sizes.applications;
        };
        fixedWidth = {
          family = "${f.monospace.name}";
          pointSize = f.sizes.terminal;
        };
        small = {
          family = general.family;
          pointSize = f.sizes.desktop;
        };
        toolbar = small;
        menu = small;
        windowTitle = small;
      };
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

    zsh.syntaxHighlighting.styles = {
      ## General
      ### Diffs
      ### Markup
      ## Classes
      # Comments
      comment = "fg=${c.base04}";
      ## Constants
      ## Entitites
      ## Functions/methods
      alias = "fg=${c.base0B}";
      suffix-alias = "fg=${c.base0B}";
      global-alias = "fg=${c.base0B}";
      function = "fg=${c.base0B}";
      command = "fg=${c.base0B}";
      precommand = "fg=${c.base0B},italic";
      autodirectory = "fg=${c.base09},italic";
      single-hyphen-option = "fg=${c.base09}";
      double-hyphen-option = "fg=${c.base09}";
      back-quoted-argument = "fg=${c.base0E}";
      ## Keywords
      ## Built ins
      builtin = "fg=${c.base0B}";
      reserved-word = "fg=${c.base0B}";
      hashed-command = "fg=${c.base0B}";
      ## Punctuation
      commandseparator = "fg=${c.base08}";
      command-substitution-delimiter = "fg=${c.base05}";
      command-substitution-delimiter-unquoted = "fg=${c.base05}";
      process-substitution-delimiter = "fg=${c.base05}";
      back-quoted-argument-delimiter = "fg=${c.base08}";
      back-double-quoted-argument = "fg=${c.base08}";
      back-dollar-quoted-argument = "fg=${c.base08}";
      ## Serializable / Configuration Languages
      ## Storage
      ## Strings
      command-substitution-quoted = "fg=${c.base0A}";
      command-substitution-delimiter-quoted = "fg=${c.base0A}";
      single-quoted-argument = "fg=${c.base0A}";
      single-quoted-argument-unclosed = "fg=${c.base08},bold";
      double-quoted-argument = "fg=${c.base0A}";
      double-quoted-argument-unclosed = "fg=${c.base08},bold";
      rc-quote = "fg=${c.base0A}";
      ## Variables
      dollar-quoted-argument = "fg=${c.base05}";
      dollar-quoted-argument-unclosed = "fg=${c.base08},bold";
      dollar-double-quoted-argument = "fg=${c.base05}";
      assign = "fg=${c.base05}";
      named-fd = "fg=${c.base05}";
      numeric-fd = "fg=${c.base05}";
      ## No category relevant in spec
      unknown-token = "fg=${c.base08},bold";
      path = "fg=${c.base05}";
      path_pathseparator = "fg=${c.base08}";
      path_prefix = "fg=${c.base05}";
      path_prefix_pathseparator = "fg=${c.base08}";
      globbing = "fg=${c.base05}";
      history-expansion = "fg=${c.base0E}";
      #command-substitution ="fg=?";
      #command-substitution-unquoted ="fg=?";
      #process-substitution ="fg=?";
      #arithmetic-expansion ="fg=?";
      back-quoted-argument-unclosed = "fg=${c.base08},bold";
      redirection = "fg=${c.base05}";
      arg0 = "fg=${c.base05}";
      default = "fg=${c.base05}";
      cursor = "fg=${c.base05}";
    };
  };
}
