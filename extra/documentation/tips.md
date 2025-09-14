# Tips

This file lists some notable information that helps further explain the rather odd complexities this flake contains. Additionally, this also serves as good reference page for day-to-day use of the flake.

## Table of Contents

- [Notable Hints](#notable-hints)
- [Building a NixOS ISO with the ISO config](#building-a-nixos-iso-with-the-iso-config)
- [Rebuilding NixOS+Home-Manager](#rebuilding-nixoshome-manager)
- [Update the flake's lock file](#update-the-flakes-lock-file)
- [Flakes and Trusted Config Values](#flakes-and-trusted-config-values)
- [Secrets Management](#secrets-management)
  - [Soft and Hard Secrets](#soft-and-hard-secrets)

---

## Notable Hints

Peppered throughout my configuration, I have a set of _special variables from the features module ([nixos](../nixosModules/features.nix), [home-manager](../homeModules/features.nix)), [hostVars](../nixosModules/hostVars.nix), and [userVars](../homeModules/userVars.nix)_ that all of my configs include. These variables used throughout the flake to switch between different settings per config and allows for more fine control over what settings your system will have in the resultant builds. The `features` are declared inside each feature flag import and are included when you import the relevant flag. The `hostVars` and `userVars` must be manually defined in their respective host and user configs.

My iso/vm configurations do not have explicitly defined variables as my other configs do, since null values for them assumes you are trying to build either one of these configs. The only special variables that included are those that are from any of the `host opt-in configurations` that lie under `hosts/common`, which includes the desktop environment, theme, rather to use KDE Konsole, and the stylix theming.

Anytime I mention the `$FLAKE` variable, I mean the variable that is set in the Home-Manager configuration (which points to where you installed the flake!). The default value of the `FLAKE` variable is whatever value `hostVars.configDirectory` is; which is null so you will need to make sure to declare it in your host!. For my systems, it's set to `/home/USERNAME/Documents/NixConfig`.

## Building a NixOS ISO with the ISO config

1. Download the repo onto your computer (it must have nix or NixOS already!).
2. Open the terminal and enter the repo directory.
3. Run `nix build .#nixosConfigurations.installer.config.system.build.isoImage` to build the iso (or run `just iso`)
4. Locate the _result_ folder located in the directory, and the iso will be in _result/iso_.

## Rebuilding NixOS+Home-Manager

In order to commit new changes that you made to the flake, run the command `nixos-rebuild switch --flake $FLAKE=` to rebuild and switch to the new profile. Optionally, you can add the `--accept-flake-config` parameter in order to skip the prompt asking you to accept the all of the values that `nixConfig` inside the flake.nix file specifies (it will automatically accept the proposed values).

## Update the flake's lock file

The nix dependencies/flake inputs (such as `nixpkgs`) used by the flake will strictly follow the `flake.lock` file, using the commits written into it when you (re)generate the profiles. Simply run `nix flake update --flake $FLAKE=` to update the flake inputs. If you want to save the update message and have it committed to the repo's git history, then run `nix flake update --commit-lock-file --flake $FLAKE=`. Keeping this updated is key to obtain the latest packages and modules

The repository also includes llakala's `unify` and `rbld` utilities (available from [https://github.com/llakala/menu](https://github.com/llakala/menu)), which you can use to automatically update, rebuild, and commit flake.lock updates

## Flakes and Trusted Config Values

Nix will ask you to accept the `extra-substituter` and `extra-trusted-public-key` values that the flake adds (for retrieving packages from extra binary caches like [https://nix-community.cachix.org](https://nix-community.cachix.org) and [https://nix-gaming.cachix.org](https://nix-gaming.cachix.org)); this is for speeding up evaluation time. Make sure to read through the prompts and hit 'Y' if you want to allow those changes. Otherwise, if you want to come back later and make the values trusted, you can modify the `~/.local/share/nix/trusted-settings.json` or just delete it and restart the nix daemon via `systemctl restart nix-daemon.service`.

## Secrets Management

**NOTE**: Details here are still being worked out so they change!

Repository secrets are managed via a dedicated private flake input named `nix-secrets`, with all secret data encrypted using `sops-nix`. The nix-secrets repository follows [EmergentMind's nix-secrets template](https://github.com/EmergentMind/nix-secrets-reference), which serves as the primary reference for implementation details.

For the host keys, I use the automatically generated ssh host keys that NixOS generates on first boot (the keys live in `/etc/ssh`) and I created an ssh key for my user that is only used for dealing with the secrets and nothing else. The public ssh key identities are under their respective user and host configs. These ssh keys decrypt their respective secret associated with the host and user. There are also master keys, which live on my Yubikey(s), are used to modify and encrypt the secrets, these can manage the secrets even if we lose the host keys! Rekeying is done with `sops updatekeys` inside the nix-secrets repository.
For new systems, you will need to create the ssh keys in the installer with `ssh-keyscan -t ed25519` or simply copy the already generated ssh keys from the live-image's `/etc/ssh/` into the newly mounted disks, `/mnt/etc/ssh/`; then rekey the secrets again.

Steps for rekeying/deployment for new hosts are (generally) as follows:

1. Get the ssh key dervied age keys with `cat /path/to/ssh_host_ed25519_key.pub | ssh-to-age` or run `just generate-key-host-ssh-age` to generate the age keys from the installer's ssh keys
2. Rekey the secrets (if you're using an external repo for storing your secrets,
   make sure to append the key there and push the changes so the flake can
   access the newly rekeyed secrets!)
3. If using the installer's ssh keys, use `just copy-installer-keys HOSTNAME` to move them to the new host
4. Use `just generate-age-keylist installer "LIST OF HARDWARE KEY SERIAL NUMBERS"`, to create a keys.txt that contains the identity paths of your hardware-key based age keys and then move it onto the `/var/lib/sops`
5. Copy the keys.txt created from the previous step into the installer's `~/.config/sops/age` folder

For more information on how sops-nix works in general and for more advanced functionality, refer to the [sops-nix README](https://github.com/Mic92/sops-nix/tree/master?tab=readme-ov-file#sops-nix).

### Soft and Hard Secrets

Soft secrets are evaluation-time variables that I don't want in my public nix-config, but don't need to be encrypted. These secrets are easily referred by `inputs.nix-secrets.SOFT_SECRET`. Thus you can use them directly in strings and filenames. An example of a soft secret is a work email for mbsync. Hard secrets are things like passwords and API tokens that needs to be encrypted with sops-nix.
