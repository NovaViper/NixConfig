{
  config,
  outputs,
  name,
  ...
}: let
  cfg = config.theme.stylix;
  c = config.lib.stylix.colors.withHashtag;
  f = config.stylix.fonts;

  settings = {
    users = {
      stylix = cfg.configs // {enable = outputs.lib.mkForce true;};
      nixos.stylix.image = outputs.lib.mkDefault (
        if (config.wallpaper != null)
        then config.wallpaper
        else (throw "stylix.image or wallpaper not set")
      );

      nukeFiles = ["${config.home.homeDirectory}/.config/gtk-2.0/gtkrc" "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css" "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css" "${config.home.homeDirectory}/.gtkrc-2.0"];
    };

    system-wide = {
      stylix =
        cfg.configs
        // {
          enable = outputs.lib.mkForce true;
          targets.grub.enable = false;
        };
    };
  };
in {
  options.theme.stylix = {
    enable = outputs.lib.mkEnableOption "Enable Stylix";
    system-wide = outputs.lib.mkEnableOption "Enable Stylix system-wide. This will install Stylix for all users.";
    configs = outputs.lib.mkOption {
      type = outputs.lib.types.attrs;
      default = {};
      description = ''
        Takes options defined here and directly appends them to stylix
      '';
    };
  };

  config =
    outputs.lib.mkIf cfg.enable
    (outputs.lib.mkMerge [
      (outputs.lib.mkIf (!cfg.system-wide)
        settings.users)
      (outputs.lib.mkIf cfg.system-wide {
        nixos =
          outputs.lib.trace
          "info: Enabling Stylix system-wide. This will override the configs of all users with ${name}'s config."
          settings.system-wide;
      })
      (outputs.lib.mkIf (config.defaultTerminal == "konsole") {
        programs.konsole = {
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

        xdg = {
          dataFile = {
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
        };
      })
      {
        gtk = outputs.lib.mkIf (config.stylix.polarity == "dark") {
          enable = true;
          theme.name = outputs.lib.mkForce "adw-gtk3-dark";
          gtk3.extraConfig = {gtk-application-prefer-dark-theme = true;};
          gtk4.extraConfig = {gtk-application-prefer-dark-theme = true;};
        };

        programs = {
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
                inherit (general) family;
                pointSize = f.sizes.desktop;
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
