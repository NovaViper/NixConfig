{
  config,
  lib,
  ...
}: let
  cfg = config.theme.stylix;
  c = config.lib.stylix.colors.withHashtag;
  f = config.stylix.fonts;
  hm-config = config.hm;
in {
  options.theme.stylix = {
    enable = lib.mkEnableOption "Enable Stylix" // {default = config.stylix.enable;};
  };

  config =
    lib.mkIf cfg.enable
    (lib.mkMerge [
      (lib.mkIf (config.variables.defaultTerminal == "konsole") {
        hm.programs.konsole = {
          defaultProfile = "DefaultThemed";
          profiles.DefaultThemed = {
            name = "DefaultThemed";
            colorScheme = "Stylix";
            font = {
              name = "${config.stylix.fonts.monospace.name}";
              size = config.stylix.fonts.sizes.terminal;
            };
          };
        };

        create.dataFile = {
          "konsole/Stylix.colorscheme".source = config.lib.stylix.colors {
            template = builtins.readFile ./konsole.mustache;
            extension = ".colorscheme";
          };
          /*
            "yakuake/skins/Dracula".source = fetchGit {
            url = "https://github.com/dracula/yakuake";
            rev = "591a705898763167dd5aca2289d170f91a85aa56";
          };
          */
        };
      })
      {
        nukeFiles = ["${hm-config.home.homeDirectory}/.config/gtk-2.0/gtkrc" "${hm-config.home.homeDirectory}/.config/gtk-3.0/gtk.css" "${hm-config.home.homeDirectory}/.config/gtk-4.0/gtk.css" "${hm-config.home.homeDirectory}/.gtkrc-2.0"];

        hm.gtk = lib.mkIf (config.stylix.polarity == "dark") {
          enable = true;
          theme.name = lib.mkForce "adw-gtk3-dark";
          gtk3.extraConfig = {gtk-application-prefer-dark-theme = true;};
          gtk4.extraConfig = {gtk-application-prefer-dark-theme = true;};
        };

        hm.programs = {
          rio.settings = {
            window.opacity = config.stylix.opacity.terminal;
            fonts = {
              size = f.sizes.terminal + 3; # Make it larger because fonts are really tiny using default stylix font size
              family = "${f.monospace.name}";
              emoji = {
                family = "${f.emoji.name}";
              };
            };
          };
          plasma = {
            overrideConfig = true;
            workspace.cursor = {
              theme = "${config.stylix.cursor.name}";
              inherit (config.stylix.cursor) size;
            };
            fonts = let
              general = {
                family = "${f.sansSerif.name}";
                pointSize = f.sizes.applications;
              };
              small = {
                inherit (general) family;
                pointSize = f.sizes.desktop;
              };
            in {
              inherit general small;
              fixedWidth = {
                family = "${f.monospace.name}";
                pointSize = f.sizes.terminal;
              };
              toolbar = small;
              menu = small;
              windowTitle = small;
            };
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
    ]);
}