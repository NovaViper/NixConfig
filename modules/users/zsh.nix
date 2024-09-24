{
  outputs,
  config,
  pkgs,
  ...
}:
with outputs.lib;
  outputs.lib.mkModule config "zsh" {
    modules.atuin.enable = true;

    # Forcibly Disable .zshenv
    nixos = {
      home-manager.sharedModules = [{home.file.".zshenv".enable = false;}];
      programs.zsh.enable = true;
      environment = {
        # Source zshenv without ~/.zshenv
        etc."zshenv".text = ''export ZDOTDIR="$HOME"/.config/zsh'';
        # Make zsh-completions work
        pathsToLink = ["/share/zsh"];
      };
    };

    home.packages = with pkgs;
      mkMerge [
        [
          # Terminal Decorations
          toilet # Display fancy text in terminal
          dwt1-shell-color-scripts # Display cool graphics in terminal
          libnotify
        ]

        (mkIf (isWayland config)
          (with pkgs; [wl-clipboard wl-clipboard-x11]))

        (mkIf (!isWayland config)
          (with pkgs; [xclip xsel xdotool xorg.xwininfo xorg.xprop]))
      ];

    programs = {
      # Custom colors for ls, grep and more
      dircolors.enable = true;

      # Shell extension to load and unload environment variables depending on the current directory.
      direnv = {
        enable = true;
        #config = {};
        nix-direnv.enable = true;
      };

      # Much better ls replacement
      eza = {
        enable = true;
        git = true;
        icons = true;
        extraOptions = ["--color=always" "--group-directories-first" "--classify"];
      };

      # Fancy 'find' replacement
      fd = {
        enable = true;
        hidden = true;
        ignores = [".git/" "*.bak"];
      };

      fzf = {
        enable = true;
        # Alt-C command options
        changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
        # Ctrl-T command options
        fileWidgetOptions = ["--bind 'ctrl-/:change-preview-window(down|hidden|)'"];
        # Ctrl-R command options
        historyWidgetOptions = ["--sort" "--exact"];
      };

      # smart cd command, inspired by z and autojump
      zoxide.enable = true;

      # The shell itself
      zsh = {
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
          # Add more strategies to zsh-autosuggestions
          ZSH_AUTOSUGGEST_STRATEGY = ["completion"];
        };
        initExtraFirst = ''
          # If not running interactively, don't do anything
          [[ $- != *i* ]] && return
        '';

        initExtra = ''
          # Append extra variables
          AUTO_NOTIFY_IGNORE+=("atuin" "yadm" "emacs" "nix-shell" "nix")

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

          ${
            if config.programs.tmux.enable
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
          nixos-rebuild = "noglob sudo nixos-rebuild";
          nh = "noglob nh";

          # Append HISTFILE before running autin import to make it work properly
          atuin-import =
            mkIf config.modules.atuin.enable
            "export HISTFILE && atuin import auto && unset HISTFILE";
        };
        zplug = {
          enable = true;
          zplugHome = "${config.xdg.configHome}/zsh/zplug";
          plugins = [
            # Prompts
            {
              name = "romkatv/powerlevel10k";
              tags = ["as:theme" "depth:1"];
            }
            #Docs https://github.com/jeffreytse/zsh-vi-mode#-usage
            {
              name = "jeffreytse/zsh-vi-mode";
            }
            # Fish-like Plugins
            {name = "mattmc3/zfunctions";}
            {name = "Aloxaf/fzf-tab";}
            {name = "Freed-Wu/fzf-tab-source";}
            {
              name = "MichaelAquilina/zsh-auto-notify";
            }

            # Sudo escape
            {
              name = "plugins/sudo";
              tags = ["from:oh-my-zsh"];
            }

            # Tmux integration
            (mkIf config.programs.tmux.enable {
              name = "plugins/tmux";
              tags = ["from:oh-my-zsh"];
            })

            # Nix stuff
            {
              name = "chisui/zsh-nix-shell";
            }
            # Make ZLE use system clipboard
            {name = "kutsan/zsh-system-clipboard";}
          ];
        };
      };
    };
  }
