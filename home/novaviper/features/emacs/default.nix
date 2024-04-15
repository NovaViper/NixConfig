{
  config,
  lib,
  pkgs,
  ...
}: let
  pack =
    if (config.variables.desktop.displayManager == "wayland")
    then pkgs.emacs29-pgtk
    else pkgs.emacs29;
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
      "doom" = {
        source =
          config.lib.file.mkOutOfStoreSymlink
          "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/doom";
        recursive = true;
        /*
        onChange = "${pkgs.writeShellScript "doom-change" ''
          export DOOM="${config.home.sessionVariables.EMDOTDIR}"
          if [ ! -d "$DOOM" ]; then
            ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $DOOM
            ${pkgs.gnused}/bin/sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" $DOOM/bin/org-tangle
          fi
        ''}";
        */
      };
      #"doom/yasnippets/.keep".source = builtins.toFile "keep" "";
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

      #Optional
      fd
      imagemagick
      pinentry-emacs
      zstd
      coreutils

      #Modules
      # :editor format
      clang-tools
      nodePackages.prettier
      html-tidy
      nodePackages.lua-fmt
      texlive.combined.scheme-medium
      shfmt

      #: editor parinfer
      parinfer-rust

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
