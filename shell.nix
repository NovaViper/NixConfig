# Shell for bootstrapping flake-enabled nix and other tooling
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  pkgs ?
  # If pkgs is not defined, instantiate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {},
  checks,
  ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes";
    PKCS = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    buildInputs = checks.${pkgs.system}.pre-commit-check.enabledPackages;
    nativeBuildInputs = with pkgs; [
      # Nix toolkit
      nix
      nix-output-monitor
      nix-inspect
      deadnix
      statix
      home-manager

      # Encryption tools
      vim # Needed for agenix
      age
      age-plugin-yubikey
      agenix
      gnupg
      openssh

      # Git setup
      git
      just
      git-credential-oauth
      git-crypt
      pre-commit
    ];
    shellHook = ''
      ${checks.${pkgs.system}.pre-commit-check.shellHook}
        export EDITOR=vim
    '';
  };
}
