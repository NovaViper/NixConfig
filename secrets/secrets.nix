let
  users = {
    novaviper = [
      "age1yubikey1q023pgeugaxany07tdc8vptwyc3jlh9rzlwq33a7gzndhlfe848jv8mtrvg" #yk5
    ];
  };

  systems = {
    #ryzennova = "";
    yoganova = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ03MhTAi6x4doPmJpKCf445S72eRbTftyCcfR/MDn2A root@yoganova";
  };
  allUsers = builtins.attrValues users;
  allSystems = builtins.attrValues systems;
in {
  # All
  # "tailscale.age".publicKeys = allUsers ++ allSystems.

  # User Pass
  "novaviper/pass.age".publicKeys = users.novaviper ++ allSystems;

  # Home-Manager User Secrets
  "novaviper/borg.age".publicKeys = users.novaviper;
}
