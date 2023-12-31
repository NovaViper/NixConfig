{ config, pkgs, lib, ... }:

{
  xdg.configFile = {
    "zsh/.p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/zsh/.p10k.zsh";
    "zsh/functions" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/zsh/functions";
      recursive = true;
    };
    "zsh/zsh-styles.sh".source = ../../dots/zsh/zsh-styles.sh;
    "zsh/manpages.zshrc".source = ../../dots/zsh/manpages.zshrc;
    #"zsh/zsh-functions.sh".source = ../../dots/zsh/zsh-functions.sh;
    "zsh/zsh-syntax-highlighting.sh".source =
      ../../dots/zsh/zsh-syntax-highlighting.sh;
  };

  home.packages = lib.mkMerge [
    (lib.mkIf config.variables.desktop.useWayland [
      pkgs.wl-clipboard
      pkgs.wl-clipboard-x11
    ])

    (lib.mkIf (!config.variables.desktop.useWayland) [
      pkgs.xclip
      pkgs.xsel
      pkgs.xdotool
      pkgs.xorg.xwininfo
      pkgs.xorg.xprop
    ])
  ];

  services.gpg-agent.enableZshIntegration = true;

  programs = {
    mcfly = {
      enable = true;
      enableZshIntegration = true;
      fuzzySearchFactor = 2;
      keyScheme = "vim";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      defaultKeymap = "viins";
      historySubstringSearch = {
        enable = true;
        searchUpKey = [ "$terminfo[kcuu1]" ];
        searchDownKey = [ "$terminfo[kcud1]" ];
      };
      autocd = true;
      zsh-abbr = {
        enable = true;
        #abbreviations = { };
      };
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        path = "$HOME/.config/zsh/.zsh_history";
      };
      localVariables = {
        AUTO_NOTIFY_EXPIRE_TIME = 5000; # in miliseconds
        ZVM_CURSOR_STYLE_ENABLED = false;
        SPROMPT =
          "Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [nyae] ";
        HISTTIMEFORMAT = "[%F %T] ";
        ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
        MANPAGER = "${pkgs.less}/bin/less -s -M +Gg";
      };
      initExtraFirst = ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return

        ${if config.programs.tmux.enable then ''
          # Run Tmux on startup for Alacritty
          if [ -z "$TMUX" ]; then
            ${pkgs.tmux}/bin/tmux attach >/dev/null 2>&1 || ${pkgs.tmuxp}/bin/tmuxp load ${config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
            exit
          fi
        '' else
          ""}
      '';

      initExtra = ''
        # Append extra variables
        AUTO_NOTIFY_IGNORE+=("yadm" "emacs" "nix-shell")

        source "$ZDOTDIR/manpages.zshrc"
        source "$ZDOTDIR/.p10k.zsh"
        source "$ZDOTDIR/zsh-syntax-highlighting.sh"
        source "$ZDOTDIR/zsh-styles.sh"
        #source "$ZDOTDIR/zsh-functions.sh"
        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

        ### Pyenv command
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi

        # Create shell prompt
        if [ $(tput cols) -ge '80' ] || [ $(tput cols) -ge '100' ]; then
          ${pkgs.dwt1-shell-color-scripts}/bin/colorscript exec square
          ${pkgs.toilet}/bin/toilet -f pagga "FOSS AND BEAUTIFUL" --metal
        fi
      '';

      shellAliases = {
        # Easy access to accessing Doom cli
        doom = "${config.home.sessionVariables.EMDOTDIR}/bin/doom";
        # Refresh Doom configurations and Reload Doom Emacs
        doom-config-reload =
          "${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle ${config.home.sessionVariables.DOOMDIR}/config.org && ${config.home.sessionVariables.EMDOTDIR}/bin/doom sync && systemctl --user restart emacs";
        # Substitute Doom upgrade command to account for fixing the issue of org-tangle not working
        doom-upgrade = ''
          ${config.home.sessionVariables.EMDOTDIR}/bin/doom upgrade --force && sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle
        '';
        # Download Doom Emacs frameworks
        doom-download = ''
          git clone https://github.com/hlissner/doom-emacs.git ${config.home.sessionVariables.EMDOTDIR}
        '';
        # Run fix to make org-tangle module work again
        doom-fix = ''
          sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle
        '';
        # Create Emacs config.el from my Doom config.org
        doom-org-tangle =
          "${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle ${config.home.sessionVariables.DOOMDIR}/config.org";
        # Easy Weather
        weather = "curl 'wttr.in/Baton+Rouge?u?format=3'";
        # Make gpg switch Yubikey
        gpg-switch-yubikey =
          ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

        # Make gpg smartcard functionality work again
        #fix-gpg-smartcard =
        #"pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";
        # Load PKCS11 keys into ssh-agent
        load-pkcs-key = "ssh-add -s ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
        # Remove PKCS11 keys into ssh-agent
        remove-pkcs-key =
          "ssh-add -e ${pkgs.opensc}/lib/pkcs11/opensc-pkcs11.so";
        # Remove all identities
        remove-ssh-keys = "ssh-add -D";
        # List all SSH keys in the agent
        list-ssh-key = "ssh-add -L";
        # Make resident ssh keys import from Yubikey
        load-res-keys = "ssh-keygen -K";
        # Quickly start Minecraft server
        start-minecraft-server = lib.mkIf (config.programs.mangohud.enable)
          "cd ~/Games/MinecraftServer-1.20.1/ && ./run.sh --nogui && cd || cd";
      };
      /* antidote = {
           enable = true;
           useFriendlyNames = true;
           plugins = [
             # Prompts
             "romkatv/powerlevel10k"

             #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
             "jeffreytse/zsh-vi-mode"

             # Fish-like Plugins
             "mattmc3/zfunctions"
             "Aloxaf/fzf-tab"
             "MichaelAquilina/zsh-auto-notify"

             # Sudo escape
             "ohmyzsh/ohmyzsh path:lib"
             "ohmyzsh/ohmyzsh path:plugins/sudo"

             #"ohmyzsh/ohmyzsh path:plugins/tmux"

             # Nix stuff
             "chisui/zsh-nix-shell"

             # Make ZLE use system clipboard
             "kutsan/zsh-system-clipboard"
           ];
         };
      */
      zplug = {
        enable = true;
        zplugHome = "${config.xdg.configHome}/zsh/zplug";
        plugins = [
          # Prompts
          {
            name = "romkatv/powerlevel10k";
            tags = [ "as:theme" "depth:1" ];
          }
          #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
          { name = "jeffreytse/zsh-vi-mode"; }
          { name = "mattmc3/zfunctions"; }
          { name = "Aloxaf/fzf-tab"; }
          {
            name = "MichaelAquilina/zsh-auto-notify";
          }
          # Sudo escape
          {
            name = "plugins/sudo";
            tags = [ "from:oh-my-zsh" ];
          }
          (lib.mkIf (config.programs.tmux.enable) {
            name = "plugins/tmux";
            tags = [ "from:oh-my-zsh" ];
          })
          # Nix stuff
          {
            name = "chisui/zsh-nix-shell";
          }
          # Make ZLE use system clipboard
          { name = "kutsan/zsh-system-clipboard"; }
        ];
      };
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
