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
  imports = myLib.utils.concatImports {
    paths =
      # Terminal Utils
      myLib.utils.importFromPath {
        path = ../../common/features/cli;
        dirs = ["shell/fish"];
        files = ["mcfly" "bat" "btop" "cava" "fastfetch" "git" "shell-utils" "tmux" "topgrade"];
      }
      ++ myLib.utils.importFromPath {
        path = ../../common/features;
        files = ["locales/us-english"];
      }
      # Development Environment
      ++ myLib.utils.importFromPath {
        path = ../../common/features/development;
        files = ["nix"];
      };
  };

  userVars = {
    username = "novaviper";
    fullName = "Nova Leary";
    email = "coder.nova99@mailbox.org";

    userIdentityPaths = myLib.secrets.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"];
  };

  users.users.${myself} = {
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "scanner"
      "i2c"
      "git"
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
