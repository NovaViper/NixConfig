{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  hm-config = config.hm;
  hm-lib = inputs.home-manager.lib;
  EMDOTDIR_VAR = config.home.sessionVariables.EMDOTDIR;
  DOOMDIR_VAR = config.home.sessionVariables.DOOMDIR;
  full-name = config.variables.user.fullName;
  email-address = config.variables.user.emailAddress;
  pack =
    if (lib.conds.isWayland config)
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
  lib.utilMods.mkModule config "doom-emacs" {
    hm.services.emacs = {
      enable = true;
      defaultEditor = true;
      startWithUserSession = "graphical";
      client.enable = true;
    };

    hm.programs.emacs = {
      enable = true;
      package = pack;
      extraPackages = epkgs: with epkgs; [tramp pdf-tools vterm] ++ lib.optionals hm-config.programs.mu.enable [mu4e];
    };

    create.configFile = {
      # Doom Emacs
      "doom/system-vars.el".text = ''
        ;;; ~/.config/emacs/config.el -*- lexical-binding: t; -*-

        ;; Import relevant variables from flake into emacs
        (setq user-emacs-directory "${EMDOTDIR_VAR}" ; Path to emacs config folder
              ${lib.optionalString (full-name != "") ''user-full-name "${full-name}" ; Name''}
              user-username "${hm-config.home.username}" ; username
              ${lib.optionalString (email-address != "") ''user-mail-address "${email-address}" ; Email''}
              mail_directory "${hm-config.xdg.dataHome}" ; Path to mail directory (for mu4e)
              flake-directory "${lib.flakePath hm-config}" ; Path to NixOS Flake

              ${lib.optionalString config.theme.stylix.enable ''
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

      "doom/themes/doom-stylix-theme.el" = lib.mkIf config.theme.stylix.enable {
        source = config.lib.stylix.colors {
          template = builtins.readFile ./doom-stylix-theme.el.mustache;
          extension = ".el";
        };
      };

      "doom/config.el" = lib.dots.mkDotsSymlink {
        config = config.hm;
        user = hm-config.home.username;
        source = "doom/config.el";
      };

      "doom/packages.el" = lib.dots.mkDotsSymlink {
        config = config.hm;
        user = hm-config.home.username;
        source = "doom/packages.el";
      };

      "doom/init.el" = lib.dots.mkDotsSymlink {
        config = config.hm;
        user = hm-config.home.username;
        source = "doom/init.el";
      };
    };

    hm.xdg.mimeApps = {
      associations.added = {"x-scheme-handler/mailto" = "emacs-mail.desktop";};
      defaultApplications = {
        "x-scheme-handler/mailto" = "emacs-mail.desktop";
        "text/plain" = "emacsclient.desktop";
        "text/richtext" = "emacsclient.desktop";
      };
    };

    home.sessionPath = ["${hm-config.xdg.configHome}/emacs/bin"];

    home.shellAliases = let
      # Easy access to accessing Doom cli
      doom = "${EMDOTDIR_VAR}/bin/doom";
    in {
      inherit doom;
      # Refresh Doom configurations and Reload Doom Emacs
      doom-config-reload = "${doom} +org tangle ${DOOMDIR_VAR}/config.org && ${doom} sync && systemctl --user restart emacs";
      # Download Doom Emacs frameworks
      doom-download = ''
        ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git ${EMDOTDIR_VAR}
      '';
      # Create Emacs config.el from my Doom config.org
      doom-org-tangle = "${doom} +org tangle ${DOOMDIR_VAR}/config.org";
    };

    home.activation.installDoomEmacs = hm-lib.hm.dag.entryAfter ["writeBoundary"] ''
      export DOOM="${EMDOTDIR_VAR}"
      if [ ! -d "$DOOM" ]; then
        ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $DOOM
      fi
    '';

    home.sessionVariables = {
      EMDOTDIR = "${hm-config.xdg.configHome}/emacs";
      DOOMDIR = "${hm-config.xdg.configHome}/doom";
    };

    home.packages = with pkgs; [
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
  }
