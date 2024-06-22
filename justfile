default:
    @just --list

update:
    nix flake update --refresh |& nom

update-upload:
    nix flake update --commit-lock-file |& nom

diff:
    git diff ':!flake.lock'

gen-iso:
    rm -rf result
    nix build .\#nixosConfigurations.live-image.config.system.build.isoImage |& nom

nixos-install HOST:
    sudo nixos-install --flake '.#{{HOST}}' --root /mnt --option accept-flake-config true |& nom

#disko-install DRIVE:
#    sudo nix run 'github:nix-community/disko#disko-install' -- --write-efi-boot-entries --flake '' --disk /nvme0n1 /dev/sda

disko HOST:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    hosts/{{HOST}}/hardware/disks.nix |&nom

[doc('Rekey FILE age-key secret that is under secrets/USER using the specified IDENTITY file')]
rekey USER FILE IDENTITY:
    #!/usr/bin/env bash
    # Enter into the folder for the specific user we chose
    cd secrets/{{USER}}

    # Create a temp folder to move all other secrets into and copy
    # all but the specified secret file (make sure to ignore the
    # eval-secrets.json as that doesn't get touched by agenix)
    [ -d temp ] || mkdir temp
    mv $(ls | grep -v -e {{FILE}}.age -e eval-secrets.json -e temp) temp/

    # Go back to main secrets directory and finally run the rekey command
    cd ..
    agenix -r -i {{IDENTITY}}

    # Make sure to go back into the specified user folder and move all
    # other secrets back into it and delete the temp folder
    cd {{USER}}
    mv temp/* .
    rm -d temp/

[doc('Rekey FILE age-key secret that is under secrets/USER using the SSH Host ED25519 Key')]
rekey-host USER FILE:
    #!/usr/bin/env bash
    # Enter into the folder for the specific user we chose
    cd secrets/{{USER}}

    # Create a temp folder to move all other secrets into and copy
    # all but the specified secret file (make sure to ignore the
    # eval-secrets.json as that doesn't get touched by agenix)
    [ -d temp ] || mkdir temp
    mv $(ls | grep -v -e {{FILE}}.age -e eval-secrets.json -e temp) temp/

    # Go back to main secrets directory and finally run the rekey command
    cd ..
    sudo agenix -r -i /etc/ssh/ssh_host_ed25519_key

    # Make sure to go back into the specified user folder and move all
    # other secrets back into it and delete the temp folder
    cd {{USER}}
    mv temp/* .
    rm -d temp/

[doc('Rekey FILE age-key secret that is under secrets/USER using the SSH Host ED25519 Key aswell as the specified IDENTITY file')]
rekey-multikey USER FILE IDENTITY:
    just rekey-host {{USER}} {{FILE}}
    echo "Done rekeying with ssh_host_ed25519 key, now rekeying with {{IDENTITY}}"
    just rekey {{USER}} {{FILE}} {{IDENTITY}}

show-hardware-config:
    nixos-generate-config --show-hardware-config --root /mnt

setup-partitions HOST:
    echo "Configuring disk partitions for {{HOST}}"
    echo "Erasing existing disks and creating new ones"
    nix run .\#nixosConfigurations.{{HOST}}.config.disks-create
    echo "Formatting the newly created partitions for {{HOST}}"
    nix run .\#nixosConfigurations.{{HOST}}.config.disks-format
    echo "Mounting disks"
    nix run .\#nixosConfigurations.{{HOST}}.config.disks-mount
    echo "Outputting values for hardware-configuration.nix"
    nix run .\#nixosConfigurations.{{HOST}}.config.disks-retrieve

setup-swap HOST:
    echo "Creating swapfile for {{HOST}}"
    nix run .\#nixosConfigurations.{{HOST}}.config.create-swapfile
