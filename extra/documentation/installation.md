# Installation

## About the Installation

All of my computers use a 512MB EFI partition and a ext4 partition with a swapfile that's double the RAM of my machines (with the exception of my desktop, since the ram is quite large, its swapfile is equal to that of the machine).

Home-manager is configured as a [NixOS module](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module), so when NixOS is rebuilt Home-manager is also rebuilt at the same time as a systemd service!

## First-time NixOS Install

### Automated via NixOS-Anywhere

The flake now comes with a just command called `remote-install` that completely automates the installation process for NixOS. It will automatically provision secrets, partition your disks, and install NixOS with the flake's configuration.
**NOTE**: You will still need to provide a disks config, hardware configuration file
and add the new host into the flake.nix

You can run the remote installer with `just remote-install HOSTNAME TARGET_MACHINE USER "SERIAL_NUMS_FOR_HARDWARE_KEYS"`

### Manual

1. Download a NixOS ISO or create custom one with nix experimental features and Nvidia drivers installed by following the instructions over under [Tips](tips.md); then boot into the ISO's live image environment
2. Download the repo onto the live image copy of NixOS.
3. Open the terminal and enter the repo directory.
4. Run `nix-shell` or `nix develop` to enter environment with all necessary packages to build the config properly
   - `nix-shell` is available on any version of nix. However, in order to use `nix develop`, you must have nix v2.4+, git, and have enabled the `flakes` and `nix-command` experimental features. If you are using the custom ISO as stated previously, you can use `nix develop` without having to do anything additional as the configs already have the needed configurations and dependencies.
   - JUNE 2024: `nix develop` is the recommended way to utilize the devshell, as it directly pulls the flake's overlays into itself without errors along with its other inputs, `nix-shell` **DOES NOT** important any of the flake's inputs thus causing errors when loading into it.
5. Create a folder under `hosts` with the hostname of the machine you are installing NixOS on (e.g. `hosts/HOSTNAME/`).
   - This folder will contain all of the configuration files for that host, including the filesystem/disks config, hardware config, and any other host-specific configurations.
6. Create a disks config into `hosts/HOSTNAME/config` named as `disks.nix`.
   - This file serves as the configuration for the disks on the host machine, and is used to partition, format, and mount the disks during installation.
   - You must define the `fileSystem` and any other standard NixOS filesystem-related attributes that are required for the disks you are using.
     > NOTE: Some important notes to keep in mind also:
   - Make sure to edit the `disk` and `swapSize` variables at the top of the file to point to your drive's id (using `sudo blkid`).
   - You will need to define the `config.disks-create`, `config.disks-format`, and `config.disks-mount` options, which are self-contained packages that bundle a partitioning/formatting/mounting shell script with its runtime tools.

7. From the live image, run the following (in order) to partition, format, and mount the disks for the host you specified:

   ```sh
   just disks-create HOSTNAME
   just disks-format HOSTNAME
   just disks-mount HOSTNAME
   ```

   - These are simply aliases for `nix run .#nixosConfigurations.HOSTNAME.config.disks-{create,format,mount}`, so they work straight from the flake without needing anything pre-installed.

8. Run `nixos-generate-config --show-hardware-config --no-filesystems --root /mnt` to create a base configuration file that the installer provides.
   - It is important to include `--no-filesystems`, since `disks.nix` already declares the filesystem configuration for you (including them along with the generated config will cause conflicts which will make the install fail).
9. Add any of the additional kernel modules as exactly as they appear into the `hosts/HOSTNAME/hardware-configuration` file.
10. You will need to edit the `flake.nix` to include your new hosts under `nixosConfigurations` (`homeConfigurations` will automatically include what we defined in `nixosConfigurations`).
    - The new host must be declared like the following example
      ```nix
      nixosConfigurations = builtins.mapAttrs myLib.mkHost {
        example-hostname = { # This line must be the hostname of the machine
          username = "user"; # This is required
          system = "x86_64-linux"; # This is also required
          stateVersion = "24.11"; # This, however, is optional as it will fallback to the flake's default state version in myLib/conds.nix
          profiles = ["home-pc" "some-other-profile"] # Also optional
        };
      };
      ```
    - Each host machine must include the following:
      - `config` folder, which is stores all configurations that would've normally gone inside of a `configuration.nix` file
      - `features.nix`, which includes all feature flags you want to use
      - `hardware-configuration.nix`, which was covered above
      - `hostVars.nix`, which is where host specific options are declared (such as display scaling and the configuration directory, aka the FLAKE path)
    - Each user must include a `system.nix` file, which is used to declare the NixOS configs for the user
      - Users can also include a `home.nix` file, `hosts/HOSTNAME` folder, and `config` folder for the equivalent Home-Manager configurations
11. Make sure to change the `hostVars.configDirectory` variable located under `hosts/HOSTNAME/hostVars`, as it is used in place of the `FLAKE` environment variable. Some dotfiles are sym-links that aren't located on nix store and not having the repo in the location that the variable specifies will cause the links to break. This would in turn result in some apps malfunctioning or not have your settings.
12. **IMPORTANT**: Make sure to be aware of the following caveats:
    - For modules that include `secrets`, you will **NOT** be able to directly use said modules without commenting out whatever code uses them and/or replacing them with your own secrets.
    - You could also deploy your own `nix-secrets` repo based on [EmergentMind's nix-secrets template](https://github.com/EmergentMind/nix-secrets-reference).
    - See more under [Tips](tips.md) for more information regarding these caveats
13. Run `nixos-install --flake .#HOSTNAME --root /mnt` to install NixOS with the configuration (or run `just nixos-install HOSTNAME`)
14. If you did not set a user password in the flake, make sure you use `nixos-enter` to set a password for the user!
15. Move repo into the folder located on /mnt that matches your `FLAKE` environment variable
16. Restart and the system will boot up into NixOS!

## Post Install

Once your system boots, check out [Post Install](post-install.md) for instructions for system and application setup steps that can only be done once the system is installed and booted.
