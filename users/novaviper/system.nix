{
  config,
  lib,
  myLib,
  pkgs,
  inputs,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."${myself}-password".path;
in {
  imports = myLib.utils.importFeatures "features" [
    ### Shell
    "cli/shell/fish"

    ### Terminal Utils
    "cli/utilities"
    "cli/prompt/oh-my-posh"
    "cli/deco"
    "cli/multiplexer/tmux"
    "cli/history"
    #"cli/history/atuin"
    #"cli/history/mcfly"
  ];

  userVars = {
    fullName = "Nova Leary";
    email = "coder.nova99@mailbox.org";
    userIdentityPaths = myLib.secrets.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"];
  };

  users.users.${myself} = {
    useDefaultShell = true; # Use the shell environment module declaration
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "libvirtd"
      "scanner"
      "i2c"
      "git"
      "gamemode"
    ];
    openssh.authorizedKeys.keys = lib.singleton "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICkow+KpToZkMbhpqTztf0Hz/OWP/lWPCv47QNtZc6TaAAAADnNzaDpuaXhidWlsZGVy";
    hashedPasswordFile = agenixHashedPasswordFile;
  };

  #time.timeZone = lib.mkForce "America/Chicago";

  # User Secrets
  age.secrets."${myself}-password" = myLib.secrets.mkSecretFile {
    user = myself;
    source = "passwd.age";
  };
}
