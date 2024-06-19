# Shell for bootstrapping flake-enabled nix and other tooling
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  pkgs ? import <nixpkgs> {},
  inputs,
  ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    PKCS = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    nativeBuildInputs = with pkgs; [
      nix
      vim
      home-manager
      git
      gnupg
      age
      age-plugin-yubikey
      inputs.agenix.packages.${pkgs.system}.agenix
      just
      openssh
      git-credential-oauth
      git-crypt
    ];
    shellHook = ''
      export EDITOR=vim
    '';
  };
}
