{
  config,
  lib,
  pkgs,
  ...
}: let
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
  pack =
    if (config.variables.desktop.displayManager == "wayland")
    then pkgs.emacs29-pgtk
    else pkgs.emacs29;
  emacsOpacity = builtins.toString (builtins.ceil (config.stylix.opacity.applications * 100));
  f = config.stylix.fonts;
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
in {
  services.emacs = {
    enable = true;
    defaultEditor = true;
    startWithUserSession = "graphical";
    client = {
      enable = true;
      #arguments = [ ];
    };
  };

  programs = {
    pyenv.enable = true;
    emacs = {
      enable = true;
      package = pack;
      extraPackages = epkgs: with epkgs; [tramp pdf-tools vterm];
    };
  };

  xdg = {
    configFile = {
      # Doom Emacs
      "doom/system-vars.el".text = ''
        ;;; ~/.config/emacs/config.el -*- lexical-binding: t; -*-

        ;; Import relevant variables from flake into emacs

        (setq user-emacs-directory "${config.home.sessionVariables.EMDOTDIR}" ; Path to emacs config folder
              user-full-name "Nova Leary" ; Name
              user-username "${config.home.username}" ; username
              user-mail-address "coder.nova99@mailbox.org'" ; email
              mail_directory "${config.xdg.dataHome}" ; Path to mail directory (for mu4e)

              ; Setup Fonts from Stylix
              doom-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 3)})
              doom-variable-pitch-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 3)})
              doom-big-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 5)})
              doom-symbol-font (font-spec :family "${f.emoji.name}")
        )

        ;; set opacity from stylix
        (set-frame-parameter nil 'alpha-background ${emacsOpacity})
        (add-to-list 'default-frame-alist '(alpha-background . ${emacsOpacity}))
      '';
      "doom/themes/doom-stylix-theme.el".source = config.lib.stylix.colors {
        template = builtins.readFile ./doom-stylix-theme.el.mustache;
        extension = ".el";
      };
      "doom/config.org".source = utils.linkDots "doom/config.org";
      "doom/config.el".source = utils.linkDots "doom/config.el";
      "doom/packages.el".source = utils.linkDots "doom/packages.el";
      "doom/init.el".source = utils.linkDots "doom/init.el";
      "doom/snippets/.keep".source = builtins.toFile "keep" "";
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
    activation.installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export DOOM="${config.home.sessionVariables.EMDOTDIR}"
      if [ ! -d "$DOOM" ]; then
        ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $DOOM
        ${pkgs.gnused}/bin/sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" $DOOM/bin/org-tangle
      fi
    '';
    sessionVariables = {
      EMDOTDIR = "${config.xdg.configHome}/emacs";
      DOOMDIR = "${config.xdg.configHome}/doom";
      PYENV_ROOT = "${config.xdg.dataHome}/pyenv";
      #JDTLS_PATH = "${pkgs.jdt-language-server}/share/java";
    };
    sessionPath = [
      "${config.xdg.configHome}/emacs/bin"
      "${config.home.sessionVariables.PYENV_ROOT}/bin"
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
      # :editor format
      clang-tools
      nodePackages.prettier
      html-tidy
      nodePackages.lua-fmt
      texlive.combined.scheme-medium
      shfmt

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
      openjdk17

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
      lua-language-server
      nodePackages.vscode-langservers-extracted
      #omnisharp-roslyn
      #java-language-server

      # :lang java
      #jdt-language-server

      # :lang lua
      lua-language-server

      # :lang markdown
      proselint
      pandoc
      grip

      # :lang org
      maim

      # :lang python, debugger, formatter
      (python311.withPackages
        (ps: with ps; [debugpy pyflakes isort pytest black pip nose3]))
      pyright
      pipenv

      # :lang sh
      shellcheck
      bashdb
      nodePackages.bash-language-server

      # :lang web
      stylelint
      jsbeautifier

      # :apps mu
      #mu
      #isync
    ];
  };
}
