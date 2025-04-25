default:
    @just --list

########## Flake/Nix Managemnt tools ##########
update:
    nix flake update --refresh |& nom

update-upload:
    nix flake update --commit-lock-file |& nom

diff:
    git diff ':!flake.lock'

iso:
    rm -rf result
    nix build .\#nixosConfigurations.installer.config.system.build.isoImage |& nom

eval-package HOST PACKAGE:
    nix eval --raw .\#nixosConfigurations.{{ HOST }}.pkgs.{{ PACKAGE }}

[doc('Check if secrets have been loaded (sops-nix or agenix)')]
check-secrets:
    extra/scripts/check-secrets.sh


########## NixOS Installation tools ##########
nixos-install HOST:
    sudo nixos-install --flake '.#{{ HOST }}' --root /mnt --option accept-flake-config true |& nom

disko HOST:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    hosts/{{ HOST }}/config/disko.nix |&nom

show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt
