# Shell for bootstrapping flake-enabled nix and other tooling
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    PKCS = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      sops
      gnupg
      openssh
      git-credential-oauth
      git-crypt
    ];
  };
}
