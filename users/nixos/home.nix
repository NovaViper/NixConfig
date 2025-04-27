{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  imports = myLib.utils.importFeatures "home" [
    ### Applications
    "apps/browser/floorp"
    #"apps/editor/nvim"
    "apps/terminal/ghostty"

    ### Shell
    "cli/shell/zsh"

    ### Terminal Utils
    "cli/utilities"
    "cli/prompt/oh-my-posh"
    "cli/deco"
    "cli/multiplexer/tmux"
    #"cli/history"
    "cli/history/atuin"
    #"cli/history/mcfly"
  ];

  userVars = {
    defaultTerminal = "ghostty";
    defaultBrowser = "floorp";
  };
}
