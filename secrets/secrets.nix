let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  users = {
    novaviper = [
      "age1yubikey1q023pgeugaxany07tdc8vptwyc3jlh9rzlwq33a7gzndhlfe848jv8mtrvg" #yubikey 5
    ];
  };
  systems = {
    ryzennova = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqV/Sx++yIUmgLCLuO6YNrT2Qq/iJWbmpMQtSFwgSdF root@ryzennova";
    yoganova = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiZ0B3Lvn1lD7UOTCtlX0q2yfJ4FpvwI4XWSmjwxK4R root@yoganova";
  };

  allUsers = lib.flatten (builtins.attrValues users);
  allSystems = builtins.attrValues systems;
in {
  # All
  # "tailscale.age".publicKeys = allUsers ++ allSystems;

  # User Pass
  "novaviper/passwd.age".publicKeys = users.novaviper ++ allSystems;

  # Home-Manager User Secrets
  "novaviper/borg.age".publicKeys = users.novaviper;
}
