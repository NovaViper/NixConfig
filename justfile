default:
    @just --list

########## Flake/Nix Managemnt tools ##########
[doc('Update and refresh all flake.lock file')]
update:
    nix flake update --refresh |& nom

[doc('Update flake.lock file and add changes to git')]
update-upload:
    nix flake update --commit-lock-file |& nom

[doc('Show all current staged and unstaged changes made')]
diff:
    git diff ':!flake.lock'

[doc('Create iso image from installer nixosConfiguration output')]
iso:
    rm -rf result
    nix build .\#nixosConfigurations.installer.config.system.build.isoImage |& nom

[doc('Evaluate a PACKAGE based on HOST nixosConfiguration output')]
eval-package HOST PACKAGE:
    nix eval --raw .\#nixosConfigurations.{{ HOST }}.pkgs.{{ PACKAGE }}

[doc('Check if secrets have been loaded (sops-nix or agenix)')]
check-secrets:
    extra/scripts/check-secrets.sh


########## NixOS Installation tools ##########
[doc('Run NixOS installer for HOST, monitored with nom and forcibly accept flake configs. Runs with sudo')]
nixos-install HOST:
    sudo nixos-install --flake '.#{{ HOST }}' --root /mnt --option accept-flake-config true |& nom

[doc('Create disko file for HOST')]
disko HOST:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    hosts/{{ HOST }}/config/disko.nix |&nom

[doc('Generate and display hardware config file for current machine')]
show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt


########## sops-nix tools ##########
[doc('Update the nix-secrets flake input')]
update-secret-flake:
    nix flake update nix-secrets
