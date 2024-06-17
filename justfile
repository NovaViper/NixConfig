default:
    @just --list

update:
    nix flake update --refresh

update-upload:
    nix flake update --commit-lock-file

diff:
    git diff ':!flake.lock'

gen-iso:
    rm -rf result
    nix build .\#nixosConfigurations.live-image.config.system.build.isoImage

rekey FILE:
    sops updatekeys {{FILE}}

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
