{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  features.shell = "zsh";

  # Only execute when the user actually has a functions folder
  xdg.configFile =
    let
      user = config.home.username;
      path = "zsh/functions";
    in
    lib.mkIf (builtins.pathExists (myLib.dots.getDotsPath { inherit user path; })) {
      "zsh/functions" = myLib.dots.mkDotsSymlink {
        inherit config user;
        source = path;
      };
    };

  # The shell itself
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Set keymap to vi-insert mode
    defaultKeymap = "viins";
    # Make zsh config live in ~/.config
    dotDir = ".config/zsh";
    # Automatically enter into a directory if typed directly into shell
    autocd = true;
    # Save timestamp into the history file.
    history.extended = true;
    # Fix for https://discourse.nixos.org/t/zsh-compinit-warning-on-every-shell-session/22735/6
    completionInit = "autoload -U compinit && compinit -i";

    autosuggestion = {
      enable = true;
      # We're using an local variable for this
      strategy = lib.mkForce [ ];
      highlight = "fg=8,underline";
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "cursor"
        "line"
      ];
      patterns = {
        "rm -rf *" = "fg=white,bold,bg=red";
      };
    };

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
      ZSH_AUTOSUGGEST_STRATEGY = [
        "abbreviations"
        "completion"
        "history"
      ];
    };

    shellAliases = {
      # ZSH globbing interferes with flake notation for all nix commands
      nix = "noglob nix";
      nom = "noglob nom";
      nixos-remote = "noglob nixos-remote";
      nixos-rebuild = "noglob nixos-rebuild";
      nh = "noglob nh";

      # Append HISTFILE before running autin import to make it work properly
      atuin-import = lib.mkIf config.programs.atuin.enable "export HISTFILE && atuin import auto && unset HISTFILE";
    };
  };
}
