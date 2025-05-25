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

[doc('Run nixos-rebuild on the remote host')]
build-host HOST:
    NIX_SSHOPTS="-t" nixos-rebuild --target-host {{ HOST }} --use-remote-sudo --show-trace --fast --flake '.#{{ HOST }}' switch

[doc('Run NixOS installer for HOST, monitored with nom and forcibly accept flake configs. Runs with sudo')]
nixos-install HOST:
    sudo nixos-install --flake '.#{{ HOST }}' --root /mnt --option accept-flake-config true --no-root-passwd |& nom

[doc('Create disko file for HOST')]
disko HOST:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    hosts/{{ HOST }}/config/disko.nix |&nom

[doc('Generate and display hardware config file for current machine')]
show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt

[doc('Generate the age keys.txt file needed for looking up Yubikey master identities with sops-nix CONTEXT determines if the keys.txt should be generated for nixos-install or just put in the current folder. SERIALNO is a string list of Yubikey serial numbers')]
generate-age-keylist CONTEXT *SERIALNO:
    #!/usr/bin/env sh
    # Validate CONTEXT is either "host" or "installer"
    if [ "{{ CONTEXT }}" != "host" ] && [ "{{ CONTEXT }}" != "installer" ]; then \
        echo "Error: CONTEXT must be 'host' or 'installer' (got '{{ CONTEXT }}')"; \
        echo "Usage: just generate-age-keyslist CONTEXT \"12345678 87654321\"" >&2
        exit 1; \
    fi

    # Ensure SERIALNO is not empty (we will do more validation inside the script)
    trun=$(echo '{{ SERIALNO }}' | tr -d '[:space:]')
    if [ -z "{{ SERIALNO }}" ] || [ $trun = "" ]; then \
      echo "Error: -s option is required and cannot be empty." >&2; \
      echo "Usage: just generate-age-keyslist CONTEXT \"12345678 87654321\"" >&2
      exit 1; \
    fi
    extra/scripts/get-yubikey-age.sh {{ CONTEXT }} -s "{{ SERIALNO }}"

[doc('Translate the ssh ed25519 host key into an age key')]
generate-key-host-ssh-age:
    cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age

[doc("Copy the installer's ssh ed25519 keys over into the newly created host partition")]
@copy-installer-keys HOST:
    sudo cp /etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key
    sudo cp /etc/ssh/ssh_host_ed25519_key.pub /mnt/etc/ssh/ssh_host_ed25519_key.pub
    sed -i 's/\(root@\).*/\1{{ HOST }}/' /mnt/etc/ssh/ssh_host_ed25519_key.pub
