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
    #  userIdentityPaths = myLib.secrets.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"];
  };

  #age.identityPaths = lib.mkOptionDefault (myLib.secrets.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"]);
}
