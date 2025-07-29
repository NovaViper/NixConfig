{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  imports = myLib.utils.importFeatures "home" [
    ### Shell
    "cli/shell/zsh"

    ### Terminal Utils
    "cli/utilities"
    "cli/multiplexer/tmux"
  ];

  userVars = {
    fullName = "Nova Leary";
    email = "coder.nova99@mailbox.org";
  };
}
