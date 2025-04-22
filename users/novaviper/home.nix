{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: {
  imports = myLib.utils.importFeatures "home" [
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
    fullName = "Nova Leary";
    email = "coder.nova99@mailbox.org";
  };
}
