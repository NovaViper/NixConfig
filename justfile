default:
    @just --list

########## Flake/Nix Management tools ##########

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
@iso:
    rm -rf result
    nix build .\#nixosConfigurations.installer.config.system.build.isoImage |& nom

[doc('Evaluate a PACKAGE based on HOST nixosConfiguration output')]
eval-package HOST PACKAGE:
    nix eval --raw .\#nixosConfigurations.{{ HOST }}.pkgs.{{ PACKAGE }}

[doc('Check if secrets have been loaded (sops-nix or agenix)')]
@check-secrets:
    extra/scripts/check-secrets.sh

[doc('Update a given flake input(s), {{INPUTS}}')]
@update-input *INPUTS:
    extra/scripts/update-input.sh "{{ INPUTS }}"

########## NixOS Installation tools ##########

[doc('Rebuild a remote NixOS host with the chosen action and build location. Run without arguments for options.')]
[positional-arguments]
build-host *ARGS:
    extra/scripts/build-host.sh "$@"

[doc('Remotely install NixOS and provision secrets; serials may be separate or quoted together. Run without arguments for options.')]
[positional-arguments]
remote-install *ARGS:
    extra/scripts/nixos-anywhere.sh "$@"

[doc('Run NixOS installer for HOST, monitored with nom and forcibly accept flake configs. Runs with sudo')]
nixos-install HOST:
    sudo nixos-install --flake '.#{{ HOST }}' --root /mnt --option accept-flake-config true --no-root-passwd |& nom

[confirm("This will PERMANENTLY ERASE all data on the target disks. Continue?")]
[doc('Partition the disks for HOST by running its disks-create script (run from the installer environment)')]
disks-create HOST:
    sudo nix run --experimental-features "nix-command flakes" '.#nixosConfigurations.{{ HOST }}.config.disks-create' |& nom

[confirm("This will PERMANENTLY ERASE all data on the target partitions. Continue?")]
[doc('Format the already-partitioned disks for HOST by running its disks-format script (run from the installer environment)')]
disks-format HOST:
    sudo nix run --experimental-features "nix-command flakes" '.#nixosConfigurations.{{ HOST }}.config.disks-format' |& nom

[doc('Mount the formatted disks for HOST at /mnt by running its disks-mount script (run from the installer environment)')]
disks-mount HOST:
    sudo nix run --experimental-features "nix-command flakes" '.#nixosConfigurations.{{ HOST }}.config.disks-mount' |& nom

[doc('Generate and display hardware config file for current machine')]
show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt

[doc('Generate the age keys.txt file needed for looking up Yubikey master identities with sops-nix CONTEXT determines if the keys.txt should be generated for nixos-install or just put in the current folder. SERIALNO is a string list of Yubikey serial numbers')]
generate-age-keylist *ARGS:
    extra/scripts/get-yubikey-age.sh {{ ARGS }}

[doc('Translate the ssh ed25519 host key into an age key')]
generate-key-host-ssh-age:
    cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age

[doc("Copy the installer's ssh ed25519 keys over into the newly created host partition")]
@copy-installer-keys HOST ROOT="/mnt":
    sudo mkdir {{ ROOT }}/etc/ssh -p
    sudo cp /etc/ssh/ssh_host_ed25519_key {{ ROOT }}/etc/ssh/ssh_host_ed25519_key
    sudo cp /etc/ssh/ssh_host_ed25519_key.pub {{ ROOT }}/etc/ssh/ssh_host_ed25519_key.pub
    sudo sed -i 's/\(root@\).*/\1{{ HOST }}/' {{ ROOT }}/etc/ssh/ssh_host_ed25519_key.pub
