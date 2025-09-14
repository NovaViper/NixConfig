# Installation

## About the Installation

All of my computers use a 512MB EFI partition and a ext4 partition with a swapfile that's double the RAM of my machines (with the exception of my desktop, since the ram is quite large, its swapfile is equal to that of the machine).

Home-manager is configured as a [NixOS module](https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module), so when NixOS is rebuilt Home-manager is also rebuilt at the same time as a systemd service!

## First-time NixOS Install

1. Download a NixOS ISO or create custom one with nix experimental features and Nvidia drivers installed by following the instructions over under [Tips](tips.md); then boot into the ISO's live image environment
2. Download the repo onto the live image copy of NixOS.
3. Open the terminal and enter the repo directory.
4. Run `nix-shell` or `nix develop` to enter environment with all necessary packages to build the config properly
   - `nix-shell` is available on any version of nix. However, in order to use `nix develop`, you must have nix v2.4+, git, and have enabled the `flakes` and `nix-command` experimental features. If you are using the custom ISO as stated previously, you can use `nix develop` without having to do anything additional as the configs already have the needed configurations and dependencies.
   - JUNE 2024: `nix develop` is the recommended way to utilize the devshell, as it directly pulls the flake's overlays into itself without errors along with its other inputs, `nix-shell` **DOES NOT** important any of the flake's inputs thus causing errors when loading into it.
5. Drag a pre-configured or your own disko config into `hosts/HOSTNAME` named as `disks.nix` and import into your hardware default nix file.
   - Make sure the `hosts/HOSTNAME/config/disko.nix` file to your designed partition configurations (see [disko's getting started guide](https://github.com/nix-community/disko/blob/master/docs/quickstart.md) for more!)
   - Most importantly, make sure to edit the `disk` and `swapSize` variables at the top of the file to point to your drive's id (using `sudo blkid`).
6. Run `just disko #HOSTNAME` to automatically partition the system's disks according to your `disks.nix` for the host you specified
7. Run `nixos-generate-config --show-hardware-config --no-filesystems --root /mnt` to create a base configuration file that the installer provides.
   - It is important to include `--no-filesystems` in the command, as since disko handles the filesystem configurations for you (including them along with disko will cause conflicts which will make the install fail).
8. Add any of the additional kernel modules as exactly as they appear into the `hosts/HOSTNAME/hardware-configuration` file.
9. You will need to edit the `flake.nix` to include your new hosts under `nixosConfigurations` and `homeConfigurations`.
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
10. Make sure to change the `hostVars.configDirectory` variable located under `hosts/HOSTNAME/hostVars`, as it is used in place of the `FLAKE` environment variable. Some dotfiles are sym-links that aren't located on nix store and not having the repo in the location that the variable specifies will cause the links to break. This would in turn result in some apps malfunctioning or not have your settings.
11. **IMPORTANT**: Make sure to be aware of the following caveats:
    - For modules that include `secrets`, you will **NOT** be able to directly use said modules without commenting out whatever code uses them and/or replacing them with your own secrets.
    - You could also deploy your own `nix-secrets` repo based on [EmergentMind's nix-secrets template](https://github.com/EmergentMind/nix-secrets-reference).
    - See more under [Tips](tips.md) for more information regarding these caveats
12. Run `nixos-install --flake .#HOSTNAME --root /mnt` to install NixOS with the configuration (or run `just nixos-install HOSTNAME`)
13. If you did not set a user password in the flake, make sure you use `nixos-enter` to set a password for the user!
14. Move repo into the folder located on /mnt that matches your `FLAKE` environment variable
15. Restart and the system will boot up into NixOS!

## Post Install

Once your system boots, check out [Post Install](post-install.md) for instructions for system and application setup steps that can only be done once the system is installed and booted.
