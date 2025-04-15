_: let
  default = [
    "vim"
    "nvim"
    "less"
    "more"
    "man"
    "tig"
    "watch"
    "git commit"
    "top"
    "htop"
    "ssh"
    "nano"
  ];
in {
  programs.zsh.localVariables.AUTO_NOTIFY_IGNORE = default ++ ["atuin" "yadm" "emacs" "nix-shell" "nix" "nix develop"];
}
