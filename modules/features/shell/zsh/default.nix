{
  config,
  lib,
  ...
}: let
  inherit (lib) utilMods mkIf;
  hm-config = config.hm;
in
  {
    imports = [./zshAbbr.nix];
  }
  // utilMods.mkModule config "zsh" {
    # Forcibly Disable .zshenv
    home-manager.sharedModules = [{home.file.".zshenv".enable = false;}];
    programs.zsh.enable = true;
    # Source zshenv without ~/.zshenv
    environment.etc."zshenv".text = ''export ZDOTDIR="$HOME"/.config/zsh'';
    # Make zsh-completions work
    environment.pathsToLink = ["/share/zsh"];

    # Most of the configuration is done in Home-Manager
    # Enable accompanying modules
    modules.atuin.enable = true;
    modules.oh-my-posh.enable = true;

    create.configFile = {
      "zsh/functions" = lib.dots.mkDotsSymlink {
        config = hm-config;
        user = hm-config.home.username;
        source = "zsh/functions";
      };
    };

    # The shell itself
    hm.programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
        #highlight = "underline";
      };
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      defaultKeymap = "viins";
      autocd = true;
      history.path = "${hm-config.xdg.configHome}/zsh/.zsh_history";
      localVariables = {
        # Make ZSH notifications expire, in miliseconds
        AUTO_NOTIFY_EXPIRE_TIME = 5000;
        # Make zsh-vi-mode be sourced
        ZVM_INIT_MODE = "sourcing";
        # Disable zsh-vi-mode's custom cursors
        ZVM_CURSOR_STYLE_ENABLED = false;
        # Prompt message for auto correct
        SPROMPT = "Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [ny] ";
      };
      initExtraFirst = ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return
      '';

      initExtra = ''
        # Append extra variables
        AUTO_NOTIFY_IGNORE+=("atuin" "yadm" "emacs" "nix-shell" "nix")

        # Forcibly set ZSH_AUTOSUGGEST_STRATEGY until https://github.com/nix-community/home-manager/pull/6151 is merged
        typeset -U ZSH_AUTOSUGGEST_STRATEGY # Remove any duplicate entries
        ZSH_AUTOSUGGEST_STRATEGY=("atuin" "abbreviations" "completion" "''${ZSH_AUTOSUGGEST_STRATEGY[@]}")

        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

        ### Pyenv command
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi

        # Check if sudo-command-line function is available
        if typeset -f sudo-command-line > /dev/null; then
          zle -N sudo-command-line
          bindkey "^B" sudo-command-line
          bindkey -M vicmd '^B' sudo-command-line
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

        ${
          if hm-config.programs.tmux.enable
          then ''
            # Enable fzf-tab integration with tmux
            zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
            zstyle ':fzf-tab:*' popup-min-size 100 50
          ''
          else ""
        }
      '';

      shellAliases = {
        # ZSH globbing interferes with flake notation for all nix commands
        nix = "noglob nix";
        nom = "noglob nom";
        nixos-remote = "noglob nixos-remote";
        nixos-rebuild = "noglob nixos-rebuild";
        nh = "noglob nh";

        # Append HISTFILE before running autin import to make it work properly
        atuin-import =
          mkIf hm-config.programs.atuin.enable
          "export HISTFILE && atuin import auto && unset HISTFILE";
      };
      antidote = {
        enable = true;
        useFriendlyNames = true;
        plugins = [
          # For ohmyzsh plugins
          "ohmyzsh/ohmyzsh path:lib"
          #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
          "jeffreytse/zsh-vi-mode"

          # Fish-like Plugins
          "hlissner/zsh-autopair"
          "mattmc3/zfunctions"
          "Aloxaf/fzf-tab"
          "Freed-Wu/fzf-tab-source"
          "MichaelAquilina/zsh-auto-notify"
          "olets/zsh-autosuggestions-abbreviations-strategy"

          # Tmux integration
          (mkIf hm-config.programs.tmux.enable
            "ohmyzsh/ohmyzsh path:plugins/tmux")

          # Nix stuff
          "chisui/zsh-nix-shell"

          # Make ZLE use system clipboard
          "kutsan/zsh-system-clipboard"
        ];
      };
    };
  }
