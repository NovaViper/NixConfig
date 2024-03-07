#+title: Tips
* Notable Hints
Peppered throughout my configuration, I have a set of *special variables from the user-vars module [[file:../modules/nixos/user-vars.nix][(nixos)]] [[file:../modules/home-manager/user-vars.nix][(home-manager)]]* that all of my configs include. These variables used throughout the flake to switch between different settings per config and allows for more fine control over what settings your system will have in the resultant builds.

My iso/vm configurations do not have explicitly defined variables as my other configs do, since null values for them assumes you are trying to build either one of these configs. The only special variables that included are those that are from any of the =host opt-in configurations that lie under hosts/common/optional=.

* Building a NixOS ISO with the ISO config
1. Download the repo onto your computer (it must have nix or NixOS already!).
2. Open the terminal and enter the repo directory.
3. Run =nix build .#nixosConfigurations.live-image.config.system.build.isoImage= to build the iso
4. Locate the *result* folder located in the directory, and the iso will be in *result/iso*.
