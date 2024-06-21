{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./btop.nix
    ./eza.nix
    ./fzf.nix
    ./gpg.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    nvd # Differ
    nix-output-monitor
  ];
}
