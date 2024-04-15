# Shell for bootstrapping flake-enabled nix and other tooling
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  pkgs ?
  # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock =
      (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
    PKCS = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      sops
      gnupg
      openssh
      git-credential-oauth
    ];
  };
}
