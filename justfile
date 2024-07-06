default:
    @just --list

# Flake/Nix Managemnt tools

update:
    nix flake update --refresh |& nom

update-upload:
    nix flake update --commit-lock-file |& nom

diff:
    git diff ':!flake.lock'

iso:
    rm -rf result
    nix build .\#nixosConfigurations.live-image.config.system.build.isoImage |& nom

eval-package HOST PACKAGE:
    nix eval --raw .\#nixosConfigurations.{{HOST}}.pkgs.{{PACKAGE}}

[doc('Check if secrets have been loaded (sops-nix or agenix)')]
check-secrets:
    scripts/check-secrets.sh

# NixOS Installation tools

nixos-install HOST:
    sudo nixos-install --flake '.#{{HOST}}' --root /mnt --option accept-flake-config true |& nom

disko HOST:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    hosts/{{HOST}}/hardware/disks.nix |&nom

[doc('Rekey FILE age-key secret that is under secrets/USER using the specified IDENTITY file')]
rekey USER FILE IDENTITY:
    scripts/agenix-rekey.sh {{USER}} {{FILE}} {{IDENTITY}} 0

[doc('Rekey FILE age-key secret that is under secrets/USER using the SSH Host ED25519 Key')]
rekey-host USER FILE:
    scripts/agenix-rekey.sh {{USER}} {{FILE}} /etc/ssh/ssh_host_ed25519_key 1

[doc('Rekey FILE age-key secret that is under secrets/USER using the SSH Host ED25519 Key aswell as the specified IDENTITY file')]
rekey-multikey USER FILE IDENTITY:
    just rekey-host {{USER}} {{FILE}}
    echo "Done rekeying with ssh_host_ed25519 key, now rekeying with {{IDENTITY}}"
    just rekey {{USER}} {{FILE}} {{IDENTITY}}

show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt
