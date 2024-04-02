{ config, lib, pkgs, inputs, ... }:
with lib;
let c = config.lib.stylix.colors.withHashtag;
in {

  stylix = {
    autoEnable = true;
    image = "${inputs.wallpapers}/purple-mountains-ai.png";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    override = {
      base00 = "282A36"; # Previously: "282936"
      #base01 = "3A3C4E"; # Unchanged
      base02 = "44475A"; # Previously: "4d4f68"
      base03 = "6272A4"; # Previously: "626483"
      #base04 = "62D6E8"; # Unchanged
      base05 = "F8F8F2"; # Previously: "e9e9f4"
      #base06 = "F1F2F8"; # Unchanged
      #base07 = "F7F7FB"; # Unchanged
      base08 = "FF5555"; # Previously: "ea51b2"
      base09 = "FFB86C"; # Previously: "B45BCF"
      base0A = "F1FA8C"; # Previously: "00f769"
      base0B = "50FA7B"; # Previously: "ebff87"
      base0C = "8BE9FD"; # Previously: "a1efe4"
      base0D = "BD93F9"; # Previously: "62d6e8"
      base0E = "FF79C6"; # Previously: "b45bcf"
      #base0F = "00F769"; # Unchanged
    };
    polarity = "dark";
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
    fonts = rec {
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = sansSerif;
      monospace = {
        package = pkgs.meslo-lgs-nf;
        name = "MesloLGS Nerd Font";
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
    targets = {
      kitty.variant256Colors = true;
      # Not needed because using Doom Emacs
      emacs.enable = false;
    };
  };

  theme = {
    package = pkgs.dracula-theme;
    name = "Dracula";
    nameSymbolic = "dracula";
    app.rio.name = name;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  # KDE Theming
  programs = {
    /* plasma = {
         workspace = {
           #wallpaper = "";
           #lookAndFeel = "${config.theme.name}";
           lookAndFeel = "org.kde.breezedark.desktop";
           cursorTheme = "${config.theme.cursorTheme.name}";
           iconTheme = "${config.theme.iconTheme.name}";
           colorScheme = "DraculaPurple";
           theme = "default";
         };
         configFile = {
           "gtk-3.0/settings.ini"."Settings"."gtk-theme-name".value =
             "${config.theme.name}";
           "gtk-4.0/settings.ini"."Settings"."gtk-theme-name".value =
             "${config.theme.name}";
         };
       };
    */
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
