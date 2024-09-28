{
  config,
  osConfig,
  pkgs,
  outputs,
  name,
  ...
}: let
  pack =
    if (outputs.lib.isWayland config)
    then pkgs.emacs29-pgtk
    else pkgs.emacs29;
  emacsOpacity = builtins.toString (builtins.ceil (config.stylix.opacity.applications * 100));
  f = config.stylix.fonts;
  # FIXME: Work on font sizes per device
  /*
  fSize =
  if (config.variables.machine.buildType == "desktop")
  then {
    standard = 14;
    big = 16;
  }
  else {
    standard = 16;
    big = 24;
  };
  */
in
  with outputs.lib;
    mkDesktopModule config "doom-emacs" {
      services.emacs = {
        enable = true;
        defaultEditor = true;
        startWithUserSession = "graphical";
        client = {
          enable = true;
          #arguments = [ ];
        };
      };

      programs.emacs = {
        enable = true;
        package = pack;
        extraPackages = epkgs: with epkgs; [tramp pdf-tools vterm] ++ optionals config.programs.mu.enable [mu4e];
      };

      xdg = {
        configFile = {
          # Doom Emacs
          "doom/system-vars.el".text = ''
            ;;; ~/.config/emacs/config.el -*- lexical-binding: t; -*-

            ;; Import relevant variables from flake into emacs

            (setq user-emacs-directory "${config.home.sessionVariables.EMDOTDIR}" ; Path to emacs config folder
                  ${optionalString (config.fullName != "") ''user-full-name "${config.fullName}" ; Name''}
                  user-username "${config.home.username}" ; username
                  ${optionalString (config.emailAddress != "") ''user-mail-address "${config.emailAddress}" ; Email''}
                  mail_directory "${config.xdg.dataHome}" ; Path to mail directory (for mu4e)
                  flake-directory "${config.home.sessionVariables.FLAKE}" ; Path to NixOS Flake

                  ${optionalString config.theme.stylix.enable ''
              ; Setup Fonts from Stylix
              doom-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 3)})
              doom-variable-pitch-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 3)})
              doom-big-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 5)})
              doom-symbol-font (font-spec :family "${f.emoji.name}")
            ''}
            )

            ;; set opacity from stylix
            (set-frame-parameter nil 'alpha-background ${emacsOpacity})
            (add-to-list 'default-frame-alist '(alpha-background . ${emacsOpacity}))
          '';

          "doom/themes/doom-stylix-theme.el" = mkIf config.theme.stylix.enable {
            source = config.lib.stylix.colors {
              template = builtins.readFile ./doom-stylix-theme.el.mustache;
              extension = ".el";
            };
          };
          "doom/config.el" = mkDotsSymlink {
            inherit config;
            user = config.home.username;
            source = "doom/config.el";
          };
          "doom/packages.el" = mkDotsSymlink {
            inherit config;
            user = config.home.username;
            source = "doom/packages.el";
          };
          "doom/init.el" = mkDotsSymlink {
            inherit config;
            user = config.home.username;
            source = "doom/init.el";
          };
        };

        mimeApps = {
          associations = {
            added = {"x-scheme-handler/mailto" = "emacs-mail.desktop";};
          };
          defaultApplications = {
            "x-scheme-handler/mailto" = "emacs-mail.desktop";
            "text/plain" = "emacsclient.desktop";
            "text/richtext" = "emacsclient.desktop";
          };
        };
      };

      home = {
        shellAliases = rec {
          # Easy access to accessing Doom cli
          doom = "${config.home.sessionVariables.EMDOTDIR}/bin/doom";
          # Refresh Doom configurations and Reload Doom Emacs
          doom-config-reload = "${doom} +org tangle ${config.home.sessionVariables.DOOMDIR}/config.org && ${doom} sync && systemctl --user restart emacs";
          # Download Doom Emacs frameworks
          doom-download = ''
            ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git ${config.home.sessionVariables.EMDOTDIR}
          '';
          # Create Emacs config.el from my Doom config.org
          doom-org-tangle = "${doom} +org tangle ${config.home.sessionVariables.DOOMDIR}/config.org";
        };
        activation.installDoomEmacs = hm.dag.entryAfter ["writeBoundary"] ''
          export DOOM="${config.home.sessionVariables.EMDOTDIR}"
          if [ ! -d "$DOOM" ]; then
            ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $DOOM
          fi
        '';
        sessionVariables = {
          EMDOTDIR = "${config.xdg.configHome}/emacs";
          DOOMDIR = "${config.xdg.configHome}/doom";
        };
        sessionPath = [
          "${config.xdg.configHome}/emacs/bin"
        ];
        packages = with pkgs; [
          # Doom Dependencies
          binutils
          (ripgrep.override {withPCRE2 = true;})
          gnutls
          emacs-all-the-icons-fonts

          # Optional
          imagemagick
          pinentry-emacs
          zstd
          coreutils

          # Modules
          # : editor everywhere
          kdotool

          # :editor format
          # Several languages including PHP, CSS, Angular, JavaScript,JSON,
          nodePackages.prettier
          shfmt # Sh

          # :editor parinfer
          #parinfer-rust

          # :term vterm
          cmake
          gnumake

          # :checkers spell
          (aspellWithDicts (dicts: with dicts; [en en-computers en-science]))
          hunspell
          hunspellDicts.en_US

          # :checkers grammer
          languagetool

          # :tools editorconfig
          editorconfig-core-c # per-project style config

          # :tools debugger
          nodejs
          lldb
          gdb
          unzip

          # :tools lookup, :lang org +roam
          sqlite
          wordnet

          # :tools lsp
          semgrep
          yaml-language-server
          nodePackages.vscode-langservers-extracted

          # :lang org
          maim

          # :lang sh
          shellcheck
          bashdb
          nodePackages.bash-language-server
        ];
      };
    }
