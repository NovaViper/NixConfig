{
  config,
  outputs,
  pkgs,
  ...
}: {
  programs.git = {
    userName = outputs.lib.mkForce null;
    userEmail = outputs.lib.mkForce null;
  };
}