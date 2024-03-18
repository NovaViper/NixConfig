{ config, pkgs, lib, ... }:
with lib;

{
  home.packages = mkMerge [
    (mkIf (config.variables.desktop.displayManager == "wayland")
      (with pkgs; [ wl-clipboard wl-clipboard-x11 ]))

    (mkIf (config.variables.desktop.displayManager == "x11")
      (with pkgs; [ xclip xsel xdotool xorg.xwininfo xorg.xprop ]))
  ];

  programs = {
    # Custom colors for ls, grep and more
    dircolors.enable = true;

    # Prompt
    starship.enable = true;

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
        ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
        # Make manpager use ls with color support``
        MANPAGER = "${pkgs.less}/bin/less -s -M +Gg";
      };
      initExtraFirst = ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return
      '';

      initExtra = ''
        # Append extra variables
        AUTO_NOTIFY_IGNORE+=(${
          if config.programs.atuin.enable then ''"atuin" '' else ""
        }"yadm" "emacs" "nix-shell" "nix")

        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

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

        # Create shell prompt
        fastfetch
      '';

      shellAliases = {
        # Make gpg switch Yubikey
        gpg-switch-yubikey =
          ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
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
      };
      zplug = {
        enable = true;
        zplugHome = "${config.xdg.configHome}/zsh/zplug";
        plugins = [
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
