{ config, pkgs, lib, ... }:
with lib;

{
  xdg.configFile = {
    "zsh/.p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/zsh/.p10k.zsh";
    "zsh/functions" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.FLAKE}/home/novaviper/dots/zsh/functions";
      recursive = true;
    };
  };

  home.packages = mkMerge [
    (mkIf (config.variables.desktop.displayManager == "wayland")
      (with pkgs; [ wl-clipboard wl-clipboard-x11 ]))

    (mkIf (config.variables.desktop.displayManager == "x11")
      (with pkgs; [ xclip xsel xdotool xorg.xwininfo xorg.xprop ]))
  ];

  programs = {
    # Custom colors for ls, grep and more
    dircolors.enable = true;

    # terminal file manager written in Go
    yazi = {
      enable = true;
      keymap = { };
      settings = { };
    };

    # smart cd command, inspired by z and autojump
    zoxide = {
      enable = true;
      options = [ ];
    };

    # The shell itself
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
        highlight = "underline";
      };
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      defaultKeymap = "viins";
      autocd = true;
      history.path = "${config.xdg.configHome}/zsh/.zsh_history";
      localVariables = {
        # Make ZSH notifications expire, in miliseconds
        AUTO_NOTIFY_EXPIRE_TIME = 5000;
        # Make zsh-vi-mode be sourced
        ZVM_INIT_MODE = "sourcing";
        # Disable zsh-vi-mode's custom cursors
        ZVM_CURSOR_STYLE_ENABLED = false;
        # Prompt message for auto correct
        SPROMPT =
          "Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [ny] ";
        # Add more strategies to zsh-autosuggestions
        ZSH_AUTOSUGGEST_STRATEGY = [ "completion" ];
        # Make manpager use ls with color support``
        MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      };
      initExtraFirst = ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return

        ${if config.programs.tmux.enable then ''
          # Run Tmux on startup
          if [ -z "$TMUX" ]; then
            ${pkgs.tmux}/bin/tmux attach >/dev/null 2>&1 || ${pkgs.tmuxp}/bin/tmuxp load ${config.xdg.configHome}/tmuxp/session.yaml >/dev/null 2>&1
            exit
          fi
        '' else
          ""}
      '';

      initExtra = ''
        # Append extra variables
        AUTO_NOTIFY_IGNORE+=(${
          if config.programs.atuin.enable then ''"atuin" '' else ""
        }"yadm" "emacs" "nix-shell" "nix")

        source "$ZDOTDIR/.p10k.zsh"

        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

        ### Pyenv command
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi

        # set descriptions format to enable group support
        zstyle ':completion:*:descriptions' format '[%d]'

        # set list-colors to enable filename colorizing
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # disable sorting when completing any command
        zstyle ':completion:complete:*:options' sort false

        # switch group using `,` and `.`
        zstyle ':fzf-tab:*' switch-group ',' '.'

        # trigger continuous trigger with space key
        zstyle ':fzf-tab:*' continuous-trigger 'space'

        # bind tab key to accept event
        zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'

        # accept and run suggestion with enter key
        zstyle ':fzf-tab:*' accept-line enter

        ${if config.programs.tmux.enable then ''
          # Enable fzf-tab integration with tmux
          zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
          zstyle ':fzf-tab:*' popup-min-size 100 50
        '' else
          ""}

        # Create shell prompt
        if [ $(tput cols) -ge '75' ] || [ $(tput cols) -ge '100' ]; then
          ${pkgs.dwt1-shell-color-scripts}/bin/colorscript exec square
          ${pkgs.toilet}/bin/toilet -f pagga "FOSS AND BEAUTIFUL" --metal
        fi
      '';

      shellAliases = {
        # Easy access to accessing Doom cli
        doom = mkIf (config.programs.emacs.enable)
          "${config.home.sessionVariables.EMDOTDIR}/bin/doom";
        # Refresh Doom configurations and Reload Doom Emacs
        doom-config-reload = mkIf (config.programs.emacs.enable)
          "${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle ${config.home.sessionVariables.DOOMDIR}/config.org && ${config.home.sessionVariables.EMDOTDIR}/bin/doom sync && systemctl --user restart emacs";
        # Substitute Doom upgrade command to account for fixing the issue of org-tangle not working
        doom-upgrade = mkIf (config.programs.emacs.enable) ''
          ${config.home.sessionVariables.EMDOTDIR}/bin/doom upgrade --force && sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle
        '';
        # Download Doom Emacs frameworks
        doom-download = mkIf (config.programs.emacs.enable) ''
          git clone https://github.com/hlissner/doom-emacs.git ${config.home.sessionVariables.EMDOTDIR}
        '';
        # Run fix to make org-tangle module work again
        doom-fix = mkIf (config.programs.emacs.enable) ''
          sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ${config.home.sessionVariables.EMDOTDIR}/bin/org-tangle
        '';
        # Create Emacs config.el from my Doom config.org
        doom-org-tangle = mkIf (config.programs.emacs.enable)
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
        start-minecraft-server = mkIf (config.programs.mangohud.enable)
          "cd ~/Games/MinecraftServer-1.20.1/ && ./run.sh --nogui && cd || cd";
        start-minecraft-fabric-server = mkIf (config.programs.mangohud.enable)
          "cd ~/Games/MinecraftFabricServer-1.20.1/ && java -Xmx8G -jar ./fabric-server-mc.1.20.1-loader.0.15.7-launcher.1.0.0.jar nogui && cd || cd";
        # Append HISTFILE before running autin import to make it work properly
        atuin-import = mkIf (config.programs.atuin.enable)
          "export HISTFILE && atuin import auto && export -n HISTFILE";
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
             "Freed-Wu/fzf-tab-source"
             "MichaelAquilina/zsh-auto-notify"

             # Sudo escape
             "ohmyzsh/ohmyzsh path:lib"
             "ohmyzsh/ohmyzsh path:plugins/sudo"

             # Tmux integration
             (mkIf (config.programs.tmux.enable)
               "ohmyzsh/ohmyzsh path:plugins/tmux")

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
          {
            name = "jeffreytse/zsh-vi-mode";
          }
          # Fish-like Plugins
          { name = "mattmc3/zfunctions"; }
          { name = "Aloxaf/fzf-tab"; }
          { name = "Freed-Wu/fzf-tab-source"; }
          {
            name = "MichaelAquilina/zsh-auto-notify";
          }

          # Sudo escape
          {
            name = "plugins/sudo";
            tags = [ "from:oh-my-zsh" ];
          }

          # Tmux integration
          (mkIf (config.programs.tmux.enable) {
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
  };
}
