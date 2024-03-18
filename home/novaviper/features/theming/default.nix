{ config, lib, pkgs, inputs, ... }:
with lib;
let inherit (inputs.nix-colors) colorSchemes;
in {
  colorscheme = colorSchemes.dracula;

  theme = {
    package = pkgs.dracula-theme;
    name = "Dracula";
    nameSymbolic = "dracula";
    app = {
      rio.name = config.theme.name;
      wezterm.name = "Dracula (Official)";
      fzf.colors = {
        fg = "#f8f8f2"; # foreground
        bg = "#282a36"; # background
        hl = "#bd93f9"; # purple
        "fg+" = "#f8f8f2"; # foreground
        "bg+" = "#44475a"; # current-line
        "hl+" = "#bd93f9"; # purple
        info = "#ffb86c"; # orange
        prompt = "#50fa7b"; # green
        pointer = "#ff79c6"; # pink
        marker = "#ff79c6"; # pink
        spinner = "#ffb86c"; # orange
        header = "#6272a4"; # comment
      };
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
  };

  # Configure the cursor theme
  home.pointerCursor = mkIf (config.variables.desktop.environment != null) {
    package = config.theme.cursorTheme.package;
    name = config.theme.cursorTheme.name;
    size = config.theme.cursorTheme.size;
    gtk.enable = config.gtk.enable;
    x11.enable = true;
  };

  # KDE Theming
  programs = {
    plasma = {
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
        "gtk-3.0/settings.ini"."Settings"."gtk-theme-name" =
          "${config.theme.name}";
        "gtk-4.0/settings.ini"."Settings"."gtk-theme-name" =
          "${config.theme.name}";
      };
    };
    zsh.syntaxHighlighting.styles = {
      ## General
      ### Diffs
      ### Markup
      ## Classes
      # Comments
      comment = "fg=#6272A4";
      ## Constants
      ## Entitites
      ## Functions/methods
      alias = "fg=#50FA7B";
      suffix-alias = "fg=#50FA7B";
      global-alias = "fg=#50FA7B";
      function = "fg=#50FA7B";
      command = "fg=#50FA7B";
      precommand = "fg=#50FA7B,italic";
      autodirectory = "fg=#FFB86C,italic";
      single-hyphen-option = "fg=#FFB86C";
      double-hyphen-option = "fg=#FFB86C";
      back-quoted-argument = "fg=#BD93F9";
      ## Keywords
      ## Built ins
      builtin = "fg=#8BE9FD";
      reserved-word = "fg=#8BE9FD";
      hashed-command = "fg=#8BE9FD";
      ## Punctuation
      commandseparator = "fg=#FF79C6";
      command-substitution-delimiter = "fg=#F8F8F2";
      command-substitution-delimiter-unquoted = "fg=#F8F8F2";
      process-substitution-delimiter = "fg=#F8F8F2";
      back-quoted-argument-delimiter = "fg=#FF79C6";
      back-double-quoted-argument = "fg=#FF79C6";
      back-dollar-quoted-argument = "fg=#FF79C6";
      ## Serializable / Configuration Languages
      ## Storage
      ## Strings
      command-substitution-quoted = "fg=#F1FA8C";
      command-substitution-delimiter-quoted = "fg=#F1FA8C";
      single-quoted-argument = "fg=#F1FA8C";
      single-quoted-argument-unclosed = "fg=#FF5555";
      double-quoted-argument = "fg=#F1FA8C";
      double-quoted-argument-unclosed = "fg=#FF5555";
      rc-quote = "fg=#F1FA8C";
      ## Variables
      dollar-quoted-argument = "fg=#F8F8F2";
      dollar-quoted-argument-unclosed = "fg=#FF5555";
      dollar-double-quoted-argument = "fg=#F8F8F2";
      assign = "fg=#F8F8F2";
      named-fd = "fg=#F8F8F2";
      numeric-fd = "fg=#F8F8F2";
      ## No category relevant in spec
      unknown-token = "fg=#FF5555";
      path = "fg=#F8F8F2";
      path_pathseparator = "fg=#FF79C6";
      path_prefix = "fg=#F8F8F2";
      path_prefix_pathseparator = "fg=#FF79C6";
      globbing = "fg=#F8F8F2";
      history-expansion = "fg=#BD93F9";
      #command-substitution ="fg=?";
      #command-substitution-unquoted ="fg=?";
      #process-substitution ="fg=?";
      #arithmetic-expansion ="fg=?";
      back-quoted-argument-unclosed = "fg=#FF5555";
      redirection = "fg=#F8F8F2";
      arg0 = "fg=#F8F8F2";
      default = "fg=#F8F8F2";
      cursor = "standout";
    };
  };
}
