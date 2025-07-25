{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
{
  imports = myLib.utils.importFeatures "home" [
    ### Applications
    "apps/editor/neovim"

    ### CLI
    "cli/dev"
  ];

  programs.neovide.enable = lib.mkForce false;

  userVars = {
    defaultEditor = "neovim";
  };

  programs.git = {
    userName = "";
    userEmail = "";
  };
}
