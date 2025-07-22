# Post Installation

## Note

Some of these steps require an active internet connection! So it is recommended to have a place where you have stable internet before go through these steps.

## App Setup

Some apps may need additional commands to be ran in order to be fully functional.

### Emacs

**NOTE**: I also have included some ZSH/Fish aliases for managing Doom Emacs:

- `doom` - Nickname for the Doom Emacs cli so you don't have to repeatedly type `~/.config/emacs/bin/doom`
- `doom-download` - Downloads the Doom Emacs Github repo
- `doom-org-tangle` - Easily run Doom's org tangle script to tangle the config.org file for Doom Emacs (use only if you have a literate configuration similar to the one I use)
- `doom-config-reload` - Creates the Doom Emacs files from the literate config file, runs `doom sync` to sync the changes made from the config, and then reloads the systemd service for Emacs (since I use emacsclient and its activated with systemd)

While standard Emacs is installed and can be used as normally (if you remove all instances of doom emacs declared in the feature module for it), I use the framework [Doom Emacs](https://github.com/doomemacs/doomemacs). Before you want to install Doom Emacs, make sure to stop the emacs user service with the command `systemctl --user stop emacs.service` and delete the `.emacs.d` folder located under your home directory (it will be hidden so you'll need to show hidden files in order to see it in your file manager). This is actually isn't the case for installation of NixOS from the official ISOs. This is because Home Manager isn't immediately activated (which is what the declaration depends on), so you have to download the Doom Emacs git repo with `git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs` first; then run the installation command for Doom Emacs. This will take a while so be patient! Installing Doom Emacs requires internet connection as it must download a large number of packages!

Update: 9/11/2024, The [long-standing org-tangle bug](https://github.com/doomemacs/doomemacs/issues/6267) has been fixed, rendering the sed command I mentioned in the previous docs useless and therefore all mention of the command is removed.

### SteamVR

- The vrcompositor for SteamVR requires superuser permissions to function properly, so you must run the following command prior to starting SteamVR:

```shell
setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
```

This command is also included within the activation script under `modules/users/gaming/vr.nix`. So all that would need to be ran is `nixos-rebuild switch --flake $FLAKE=`. This activation script may need to be ran again upon after installation since activation scripts do not function on installation.

### Flatpak

NOTE: My flatpak feature flag in `modules/linux/services/flatpak.nix` includes symlink that downloads the Flatpak repository into the `/etc` folder, thus making sure the repo is already included upon booting up NixOS!

- Just enabling `services.flatpak.enable` isn't enough to fully enable Flatpak support. You will need to run the following command in order to install the flatpak repository:

```shell
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
