{ config, pkgs, lib, ... }:

{
  #home.sessionPath = [ "$HOME/.local/bin:$PYENV_ROOT/bin" ];

  xdg.configFile = {
    "zsh/.p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
      (/etc/nixos/nixos-config/home/novaviper/dots/zsh/.p10k.zsh);

    "zsh/zsh-styles.sh".source = ../../dots/zsh/zsh-styles.sh;
    "zsh/zsh-functions.sh".source = ../../dots/zsh/zsh-functions.sh;
  };

  home.packages = with pkgs; [ wl-clipboard wl-clipboard-x11 ];

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

    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    #nix-index = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      defaultKeymap = "viins";
      historySubstringSearch.enable = true;
      autocd = true;
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        path = "$HOME/.config/zsh/.zsh_history";
      };
      initExtraFirst = ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return
      '';

      initExtra = ''
        source "$ZDOTDIR/.p10k.zsh"
        #source "$ZDOTDIR/zsh-syntax-highlighting.sh"
        source "$ZDOTDIR/zsh-styles.sh"
        source "$ZDOTDIR/zsh-functions.sh"
        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

        ### Pyenv command
        #if command -v pyenv 1>/dev/null 2>&1; then
        #  eval "$(pyenv init -)"
        #fi


        # Append extra variables
        AUTO_NOTIFY_IGNORE+=("yadm" "emacs")


        if [[ ! $TMUX ]]; then
            ${pkgs.tmux}/bin/tmux attach || ${pkgs.tmuxp}/bin/tmuxp load ~/.config/tmuxp/session.yaml
        fi

        # Create shell prompt
        if [[ $(tput cols) -ge '75' ]]; then
          ${pkgs.dwt1-shell-color-scripts}/bin/colorscript exec square
          ${pkgs.toilet}/bin/toilet -f pagga "FOSS AND BEAUTIFUL" --metal
        fi
      '';

      shellAliases = {
        # Easy access to accessing Doom cli
        doom = "$EMDOTDIR/bin/doom";
        # Refresh Doom configurations and Reload Doom Emacs
        doom-config-reload =
          "$EMDOTDIR/bin/org-tangle $DOOMDIR/config.org && $EMDOTDIR/bin/doom sync && systemctl --user restart emacs";
        # Substitute Doom upgrade command to account for fixing the issue of org-tangle not working
        doom-upgrade = ''
          $EMDOTDIR/bin/doom upgrade --force && sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" $EMDOTDIR/bin/org-tangle
        '';
        # Easy install Doom Emacs frameworks
        doom-download = ''
          git clone https://github.com/hlissner/doom-emacs.git $EMDOTDIR && $EMDOTDIR/bin/doom install && sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" $EMDOTDIR/bin/org-tangle
        '';
        # Create Emacs config.el from my Doom config.org
        org-tangle = "$EMDOTDIR/bin/org-tangle $DOOMDIR/config.org";
        # Easy Weather
        weather = "curl 'wttr.in/Baton+Rouge?u?format=3'";
        # Make gpg switch Yubikey
        gpg-switch-yubikey =
          ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
        # Make gpg smartcard functionality work again
        fix-gpg-smartcard =
          "pkill gpg-agent && sudo systemctl restart pcscd.service && sudo systemctl restart pcscd.socket && gpg-connect-agent /bye";
        # Make ssh keys import from Yubikey
        import-ssh-keys = "ssh-keygen -K";
        # Quickly start Minecraft server
        start-minecraft-server =
          "cd ~/Games/MinecraftServer-1.20.1/ && ./run.sh --nogui && cd || cd";
      };

      localVariables = {
        AUTO_NOTIFY_EXPIRE_TIME = 5000; # in miliseconds
        ZVM_CURSOR_STYLE_ENABLED = false;
        SPROMPT =
          "Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [nyae] ";
        HISTTIMEFORMAT = "[%F %T] ";
        ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
        #ZFUNCDIR="\${ZDOTDIR:-$HOME/.config/zsh}/functions";
      };

      antidote = {
        enable = true;
        useFriendlyNames = true;
        plugins = [
          # Prompts
          "romkatv/powerlevel10k"

          #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
          "jeffreytse/zsh-vi-mode"

          # Fish-like Plugins
          #"mattmc3/zfunctions"
          "Aloxaf/fzf-tab"
          "MichaelAquilina/zsh-auto-notify"

          # Sudo escape
          "ohmyzsh/ohmyzsh path:lib"
          "ohmyzsh/ohmyzsh path:plugins/sudo"

          # Nix stuff
          "chisui/zsh-nix-shell"

          # Make ZLE use system clipboard
          "kutsan/zsh-system-clipboard"
        ];
      };

      /* zplug = {
           enable = true;
           zplugHome = "${config.xdg.configHome}/zsh/zplug";
           plugins = [
             {
               name = "romkatv/powerlevel10k";
               tags = [ "as:theme" "depth:1" ];
             }
             #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
             {
               name = "jeffreytse/zsh-vi-mode";
             }
             #{ name = "mattmc3/zfunctions"; tags = [ from:gh-r ]; }
             { name = "Aloxaf/fzf-tab"; }
             { name = "MichaelAquilina/zsh-auto-notify"; }
             {
               name = "plugins/sudo";
               tags = [ "from:oh-my-zsh" ];
             }
             { name = "chisui/zsh-nix-shell"; }
           ];
         };
      */
    };
  };
}
