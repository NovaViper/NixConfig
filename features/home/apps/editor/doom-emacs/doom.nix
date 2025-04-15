{
  osConfig,
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  # Utility variables
  username = config.home.username;
  userVars = opt: myLib.utils.getUserVars opt config;

  EMDOTDIR_VAR = config.home.sessionVariables.EMDOTDIR;
  DOOMDIR_VAR = config.home.sessionVariables.DOOMDIR;

  # Shorthand references
  full-name = userVars "fullName";
  email-address = userVars "email";
  pack =
    if (osConfig.features.useWayland)
    then pkgs.emacs-pgtk
    else pkgs.emacs;
  # FIXME: Work on Stylix
  #emacsOpacity = builtins.toString (builtins.ceil (config.stylix.opacity.applications * 100));
  #f = config.stylix.fonts;
in {
  services.emacs = {
    enable = true;
    defaultEditor = lib.mkIf (userVars "defaultEditor" == "doom-emacs") true;
    startWithUserSession = "graphical";
    client.enable = true;
  };

  programs.emacs = {
    enable = true;
    package = pack;
    extraPackages = epkgs: with epkgs; [tramp pdf-tools vterm] ++ lib.optionals config.programs.mu.enable [mu4e];
  };

  xdg.configFile = {
    # Doom Emacs
    "doom/system-vars.el".text = ''
      ;;; ~/.config/emacs/config.el -*- lexical-binding: t; -*-

      ;; Import relevant variables from flake into emacs
      (setq user-emacs-directory "${EMDOTDIR_VAR}" ; Path to emacs config folder
            ${lib.optionalString (full-name != "") ''user-full-name "${full-name}" ; Name''}
            user-username "${username}" ; username
            ${lib.optionalString (email-address != "") ''user-mail-address "${email-address}" ; Email''}
            mail_directory "${config.accounts.email.maildirBasePath}" ; Path to mail directory (for mu4e)
            flake-directory "${myLib.flakePath config}" ; Path to NixOS Flake
      )
    '';

    # FIXME: Figure out what to do with Stylix
    /*
      "doom/system-vars.el".text = ''
       ;;; ~/.config/emacs/config.el -*- lexical-binding: t; -*-

       ;; Import relevant variables from flake into emacs
       (setq user-emacs-directory "${EMDOTDIR_VAR}" ; Path to emacs config folder
             ${lib.optionalString (full-name != "") ''user-full-name "${full-name}" ; Name''}
             user-username "${username}" ; username
             ${lib.optionalString (email-address != "") ''user-mail-address "${email-address}" ; Email''}
             mail_directory "${config.accounts.email.maildirBasePath}" ; Path to mail directory (for mu4e)
             flake-directory "${myLib.flakePath config}" ; Path to NixOS Flake

             ${lib.optionalString config.stylix.enable ''
        ; Setup Fonts from Stylix
        doom-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 3)})
        doom-variable-pitch-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 3)})
        doom-big-font (font-spec :family "${f.monospace.name}" :size ${toString (f.sizes.terminal + 5)})
        doom-symbol-font (font-spec :family "${f.emoji.name}")
      ''}
       )

      ${lib.optionalString config.stylix.enable ''
        ;; set opacity from stylix
        (set-frame-parameter nil 'alpha-background ${emacsOpacity})
        (add-to-list 'default-frame-alist '(alpha-background . ${emacsOpacity}))
      ''}
    '';
    */

    /*
      "doom/themes/doom-stylix-theme.el" = lib.mkIf config.theme.stylix.enable {
      source = config.lib.stylix.colors {
        template = builtins.readFile ./doom-stylix-theme.el.mustache;
        extension = ".el";
      };
    };
    */

    "doom/config.el" = myLib.dots.mkDotsSymlink {
      config = config;
      user = username;
      source = "doom/config.el";
    };

    "doom/packages.el" = myLib.dots.mkDotsSymlink {
      config = config;
      user = username;
      source = "doom/packages.el";
    };

    "doom/init.el" = myLib.dots.mkDotsSymlink {
      config = config;
      user = username;
      source = "doom/init.el";
    };
  };

  xdg.mimeApps = {
    associations.added = {"x-scheme-handler/mailto" = "emacs-mail.desktop";};
    defaultApplications = {
      "x-scheme-handler/mailto" = "emacs-mail.desktop";
      "text/plain" = "emacsclient.desktop";
      "text/richtext" = "emacsclient.desktop";
    };
  };

  home.sessionPath = ["${config.xdg.configHome}/emacs/bin"];

  home.shellAliases = let
    # Easy access to accessing Doom cli
    doom = "${EMDOTDIR_VAR}/bin/doom";
  in {
    inherit doom;
    # Refresh Doom configurations and Reload Doom Emacs
    doom-config-reload = "${doom} +org tangle ${DOOMDIR_VAR}/config.org && ${doom} sync && systemctl --user restart emacs";
    # Download Doom Emacs frameworks
    doom-download = ''
      ${lib.getExe pkgs.git} clone https://github.com/hlissner/doom-emacs.git ${EMDOTDIR_VAR}
    '';
    # Create Emacs config.el from my Doom config.org
    doom-org-tangle = "${doom} +org tangle ${DOOMDIR_VAR}/config.org";
  };

  home.activation.installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export DOOM="${EMDOTDIR_VAR}"
    if [ ! -d "$DOOM" ]; then
      ${lib.getExe pkgs.git} clone https://github.com/hlissner/doom-emacs.git $DOOM
    fi
  '';

  home.sessionVariables = {
    EMDOTDIR = "${config.xdg.configHome}/emacs";
    DOOMDIR = "${config.xdg.configHome}/doom";
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
