{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  primaryUserOpts = opts: myLib.utils.getMainUserHMVar opts config;
  shellType = shell: if (primaryUserOpts "features.shell") == shell then true else false;
in
{
  users.defaultUserShell =
    if shellType "fish" then
      pkgs.fish
    else if shellType "zsh" then
      pkgs.zsh
    else
      pkgs.bash;

  # Broken for fish so make sure to disable it when it's enabled
  programs.command-not-found.enable = !shellType "fish";

  # Enable NixOS module
  programs.fish = {
    enable = shellType "fish";
    # Translate bash scripts to fish
    useBabelfish = true;
  };

  environment.pathsToLink =
    lib.optional (shellType "fish") "/share/fish" ++ lib.optional (shellType "zsh") "/share/zsh";

  # Enable NixOS module for Fish
  programs.zsh = {
    enable = shellType "zsh";

    # Since we handle Zsh completion in home.nix via home-manager, we set this
    # to false to avoid calling compinit multiple times.
    enableCompletion = lib.mkForce (!shellType "zsh");
  };

  # Source zshenv without ~/.zshenv
  environment.etc."zshenv" = lib.mkIf (shellType "zsh") {
    text = ''export ZDOTDIR="$HOME"/.config/zsh'';
  };
}
