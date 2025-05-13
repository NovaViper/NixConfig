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
    sudo nixos-install --flake '.#{{ HOST }}' --root /mnt --option accept-flake-config true --no-root-passwd |& nom

[doc('Create disko file for HOST')]
disko HOST:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    hosts/{{ HOST }}/config/disko.nix |&nom

[doc('Generate and display hardware config file for current machine')]
show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt

[doc('Update the nix-secrets flake input')]
update-secret-flake:
    nix flake update nix-secrets

[doc('Generate the age keys.txt file needed for looking up Yubikey master identities with sops-nix CONTEXT determines if the keys.txt should be generated for nixos-install or just put in the current folder. SERIALNO is a string list of Yubikey serial numbers')]
generate-age-keys-list CONTEXT *SERIALNO:
    #!/usr/bin/env sh
    # Validate CONTEXT is either "host" or "installer"
    if [ "{{ CONTEXT }}" != "host" ] && [ "{{ CONTEXT }}" != "installer" ]; then \
        echo "Error: CONTEXT must be 'host' or 'installer' (got '{{ CONTEXT }}')"; \
        echo "Usage: just generate-age-keys-list CONTEXT \"12345678 87654321\"" >&2
        exit 1; \
    fi

    # Ensure SERIALNO is not empty (we will do more validation inside the script)
    trun=$(echo '{{ SERIALNO }}' | tr -d '[:space:]')
    if [ -z "{{ SERIALNO }}" ] || [ $trun = "" ]; then \
      echo "Error: -s option is required and cannot be empty." >&2; \
      echo "Usage: just generate-age-keys-list CONTEXT \"12345678 87654321\"" >&2
      exit 1; \
    fi
    extra/scripts/get-yubikey-age.sh {{ CONTEXT }} -s "{{ SERIALNO }}"
