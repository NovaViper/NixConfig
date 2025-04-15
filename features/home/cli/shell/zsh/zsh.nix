{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  imports = [./zshAbbr.nix];
  features.shell = "zsh";

  xdg.configFile = {
    "zsh/functions" = myLib.dots.mkDotsSymlink {
      config = config;
      user = config.home.username;
      source = "zsh/functions";
    };
  };

  # The shell itself
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      # We're using an local variable for this
      strategy = lib.mkForce [];
      #highlight = "underline";
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
      SPROMPT = "Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [ny] ";
      # Add more Zsh Autosuggestion strategies
      ZSH_AUTOSUGGEST_STRATEGY = ["abbreviations" "completion" "history"];
    };
    initExtraFirst = lib.concatStringsSep "\n" [
      ''
        # If not running interactively, don't do anything
        [[ $- != *i* ]] && return
      ''
    ];

    initExtra = lib.concatStringsSep "\n" [
      ''
        # Append extra variables
        AUTO_NOTIFY_IGNORE+=("atuin" "yadm" "emacs" "nix-shell" "nix")

        setopt beep CORRECT # Enable terminal bell and autocorrect
        autoload -U colors && colors # Enable colors

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
      ''
      (lib.optionalString config.programs.pyenv.enable ''
        ### Pyenv command
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi
      '')
      (
        lib.optionalString config.programs.fzf.enable ''
          # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
          zstyle ':completion:*' menu no

          # disable sorting when completing any command
          zstyle ':completion:complete:*:options' sort false

          # switch group using `<` and `>`
          zstyle ':fzf-tab:*' switch-group '<' '>'

          # trigger continuous trigger with space key
          zstyle ':fzf-tab:*' continuous-trigger 'space'

          # bind tab key to accept event
          zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'

          # accept and run suggestion with enter key
          zstyle ':fzf-tab:*' accept-line enter

          #### FZF-TAB SUGGESTION ADDITIONS ####
          # give a preview of commandline arguments when completing `kill`
          zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
          zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
            '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
          zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

          # preview environment variable
          zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
            fzf-preview 'echo ''${(P)word}'

          # Show systemd unit status
          zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

          # Show git
          # it is an example. you can change it
          zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
            'git diff $word | delta'
          zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
            'git log --color=always $word'
          zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
            'git help $word | bat -plman --color=always'
          zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
            'case "$group" in
            "commit tag") git show --color=always $word ;;
            *) git show --color=always $word | delta ;;
            esac'
          zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
            'case "$group" in
            "modified file") git diff $word | delta ;;
            "recent commit object name") git show --color=always $word | delta ;;
            *) git log --color=always $word ;;
            esac'

          # Preview tldr
          zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color always $word'

          # Show command preview
          zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
            '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "''${(P)word}"'

          ${
            lib.optionalString config.programs.eza.enable ''
              # preview directory's content with eza when completing cd or any path
              zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
              zstyle ':fzf-tab:complete:*:*' fzf-preview 'eza -1 --color=always ''${(Q)realpath}'
            ''
          }

          ${
            lib.optionalString config.programs.tmux.enable ''
              # Enable fzf-tab integration with tmux
              zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
              zstyle ':fzf-tab:*' popup-min-size 100 20
            ''
          }
        ''
      )
    ];

    shellAliases = {
      # ZSH globbing interferes with flake notation for all nix commands
      nix = "noglob nix";
      nom = "noglob nom";
      nixos-remote = "noglob nixos-remote";
      nixos-rebuild = "noglob nixos-rebuild";
      nh = "noglob nh";

      # Append HISTFILE before running autin import to make it work properly
      atuin-import =
        lib.mkIf config.programs.atuin.enable
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
        "MichaelAquilina/zsh-auto-notify"
        "olets/zsh-autosuggestions-abbreviations-strategy"

        # Tmux integration
        (lib.mkIf config.programs.tmux.enable
          "ohmyzsh/ohmyzsh path:plugins/tmux")

        # Make ZLE use system clipboard
        "kutsan/zsh-system-clipboard"
      ];
    };
  };
}
