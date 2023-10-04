{ config, lib, pkgs, ... }:

{

  services.emacs = {
    enable = true;
    startWithUserSession = "graphical";
    #socketActivation.enable = true;
    client = {
      enable = true;
      #arguments = [ ];
    };
  };

  programs = {
    emacs = {
      enable = true;
      #package = pkgs.emacs-gtk;
    };
    pyenv.enable = true;
  };

  /* home.persistence = {
       "/persist/home/novaviper".directories = [ ".config/emacs" ];
     };
  */

  xdg = {
    configFile = {
      "doom" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/doom";
        recursive = true;
        onChange = "${pkgs.writeShellScript "doom-change" ''
          export DOOM="${config.home.sessionVariables.EMDOTDIR}"
          if [ ! -d "$DOOM" ]; then
            ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $DOOM
            ${pkgs.gnused}/bin/sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" $DOOM/bin/org-tangle
          fi
        ''}";
      };
      #"doom/yasnippets/.keep".source = builtins.toFile "keep" "";
    };

    mimeApps = {
      associations = {
        added = { "x-scheme-handler/mailto" = "emacs-mail.desktop"; };
      };
      defaultApplications = {
        "x-scheme-handler/mailto" = "emacs-mail.desktop";
      };
    };
  };

  home = {
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
      (ripgrep.override { withPCRE2 = true; })
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
      texlive.combined.scheme-full
      nixfmt
      shfmt

      #: editor parinfer
      parinfer-rust

      # :checkers spell
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
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
      yaml-language-server
      nodePackages.vscode-langservers-extracted
      omnisharp-roslyn
      java-language-server

      # :tools pdf
      #emacsPackages.pdf-tools

      # :os tty
      #xclip
      #wl-clipboard
      #wl-clipboard-x11

      # :lang java
      #jdt-language-server

      # :lang lua
      lua-language-server

      # :lang markdown
      proselint
      pandoc

      # :lang python, debugger, formatter
      (python310.withPackages
        (ps: with ps; [ debugpy pyflakes isort pytest black pip ]))
      pyright

      # :lang sh
      shellcheck
      bashdb
      nodePackages.bash-language-server

      # :apps mu
      #mu
      #isync
    ];
  };
}
