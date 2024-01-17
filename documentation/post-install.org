#+title: Post Installation

* Note
Some of these steps require an active internet connection! So it is recommended to have a place where you have stable internet before go through these steps.

* App Setup
Some apps may need additional commands to be ran in order to be fully functional.

** Emacs
*NOTE*: I also have included some ZSH aliases for managing Doom Emacs:
- =doom-download= - Downloads the Doom Emacs Github repo
- =doom-fix= - Fixes a long-standing bug that breaks org-tangle
- =doom-upgrade= - Resets the local repo and runs the standard =doom update= command and then reapplies the org-tangle fix
- =doom-org-tangle= - Easily run =emacs/bin/org-tangle= to tangle the config.org file for Doom Emacs (use only if you have a literate configuration similar to the one I use)
- =doom-config-reload= - Creates the Doom Emacs files from the literate config file, runs =doom sync= to sync the changes made from the config, and then reloads the systemd service for Emacs (since I use emacsclient and its activated with systemd)

While standard Emacs is installed and can be used as normally (if you remove all instances of doom emacs declared in the feature module for it), I use the framework [[https://github.com/doomemacs/doomemacs][Doom Emacs]]. Before you want to install Doom Emacs, make sure to stop the emacs user service with the command =systemctl --user stop emacs.service= and delete the =.emacs.d= folder located under your home directory (it will be hidden so you'll need to show hidden files in order to see it in your file manager). +The declaration for it under =home/USERNAME/features/emacs= already downloads the repo for Doom Emacs, so all one must do is run the following commands+ This is actually isn't the case for installation of NixOS from the official ISOs. This is because Home Manager isn't immediately activated (which is what the declaration depends on), so you have to download the Doom Emacs git repo with =git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs= first; then after it downloads you run the following commands:
#+begin_src shell
sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ~/.config/emacs/bin/org-tangle
~/.config/emacs/bin/doom install
#+end_src
The first command fixes a [[https://github.com/doomemacs/doomemacs/issues/6267][long-standing bug]] that breaks org-tangle. and the second one is the actual installation command for Doom Emacs. This will take a while so be patient! Installing Doom Emacs requires internet connection as it must download a large number of packages!

** SteamVR
- The vrcompositor for SteamVR requires superuser permissions to function properly, so you must run the following command prior to starting SteamVR:
#+begin_src shell
setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
#+end_src
This command is also included within the activation script under =hosts/common/optional/gaming.nix=. So all that would need to be ran is =home-manager switch --flake $FLAKE= (if using my config directly). This activation script may need to be ran again upon after installation since activation scripts do not function on installation.
