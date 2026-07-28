# Shell for bootstrapping flake-enabled nix and other tooling
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  sources ? import ./extra/npins,
  nixpkgs ? sources.nixpkgs,
  pkgs ? import nixpkgs { config.allowUnFree = true; },
  ...
}:
let
  git-hooks = import ./checks/default.nix { inherit pkgs; };
in
pkgs.mkShell {
  FLAKE = ".";
  NH_FLAKE = ".";
  NIX_CONFIG = "use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes";
  PKCS = "${pkgs.opensc}/lib/opensc-pkcs11.so";
  buildInputs = git-hooks.enabledPackages;
  nativeBuildInputs = with pkgs; [
    # Nix toolkit
    nix-output-monitor
    nix-inspect
    deadnix
    statix

    # Encryption tools/Secrets bootstrapping
    gnupg
    openssh
    vim # Needed for age/sops
    sops # This one is from the overlay
    ssh-to-age
    age-plugin-fido2-hmac
    age-plugin-yubikey
    age-plugin-tpm
    age-plugin-ledger

    # Git setup
    gitFull
    git-extras
    tig
    just
    git-credential-oauth
    git-crypt
    pre-commit
  ];
  shellHook = ''
    ${git-hooks.shellHook}
      export EDITOR=vim
  '';
}
