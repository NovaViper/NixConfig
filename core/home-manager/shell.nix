{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  primaryUserOpts = opts: myLib.utils.getMainUserHMVar opts config;
in {
  users.defaultUserShell =
    if (primaryUserOpts "features.shell") == "fish"
    then pkgs.fish
    else if (primaryUserOpts "features.shell") == "zsh"
    then pkgs.zsh
    else pkgs.bash;

  # Broken for fish so make sure to disable it when it's enabled
  programs.command-not-found.enable =
    if (primaryUserOpts "features.shell") == "fish"
    then false
    else true;

  # Enable NixOS module
  programs.fish = {
    enable =
      if (primaryUserOpts "features.shell") == "fish"
      then true
      else false;
    # Translate bash scripts to fish
    useBabelfish = true;
  };

  environment.pathsToLink =
    lib.optional ((primaryUserOpts "features.shell") == "fish") "/share/fish"
    ++ lib.optional ((primaryUserOpts "features.shell") == "zsh") "/share/zsh";

  # Enable NixOS module for Fish
  programs.zsh.enable =
    if (primaryUserOpts "features.shell") == "zsh"
    then true
    else false;
  # Source zshenv without ~/.zshenv
  environment.etc."zshenv" = lib.mkIf ((primaryUserOpts "features.shell") == "zsh") {text = ''export ZDOTDIR="$HOME"/.config/zsh'';};
}
