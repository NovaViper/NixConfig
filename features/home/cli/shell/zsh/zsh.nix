{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  features.shell = "zsh";

  xdg.configFile = {
    "zsh/functions" = myLib.dots.mkDotsSymlink {
      inherit config;
      user = config.home.username;
      source = "zsh/functions";
    };
  };

  # The shell itself
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Fix for https://discourse.nixos.org/t/zsh-compinit-warning-on-every-shell-session/22735/6
    completionInit = "autoload -U compinit && compinit -i";
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
  };
}
