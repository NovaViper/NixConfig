<div align="center">
<h1>
<img width="100" src="extra/assets/purp-nixos.svg" /> <br>
</h1>
</div>

# _My NixOS Configurations_

[![img](https://img.shields.io/badge/Built_with_Nix-white.svg?style=for-the-badge&logo=nixos&logoColor=white&color=41439a&test.svg)](https://builtwithnix.org)
[![img](https://img.shields.io/badge/Codeberg-white.svg?style=for-the-badge&logo=codeberg&logoColor=white&color=2185D0&test.svg)](https://codeberg.org/NovaViper/NixConfig)
[![img](https://img.shields.io/badge/Github-white.svg?style=for-the-badge&logo=github&logoColor=white&color=121011&test.svg)](https://github.com/NovaViper/NixConfig)
[![img](https://img.shields.io/badge/GitLab-330F63?style=for-the-badge&logo=gitlab&logoColor=white&test.svg)](https://gitlab.com/NovaViper/NixConfig)

My current NixOS (and constant changing) configuration

Note: There are upcoming changes being actively made so documentation will change and may not necessarily be update to date!

# Table of Contents

- [Highlights](#highlights)
- [References](#references)
- [Structure](#structure)
- [Installation/Usage](#installationusage)
- [Tooling and Applications I Use](#tooling-and-applications-i-use)
- [Final Note](#final-note)

# Highlights

- Multiple NixOS configurations, including laptop and desktop
- Install and partitioning commands via [just](https://github.com/casey/just)
- Declarative partitioning with [disko](https://github.com/nix-community/disko).
- Flexible NixOS and Home Manager configs through importable **_feature flags_**
- Automatically append users to multiple hosts along with specific user settings for each user with a primary user and extra users
- Modular configuration, easily add new users and machines
- Wayland/X11 Setups
- Multiple fully featured desktop environments (KDE Plasma 6)
- Live image ISO build with Nvidia drivers, experimental nix features already enabled, unfree software usage, and some nice options for cli
- Declarative themes with [stylix](https://github.com/danth/stylix)
- Deployment of secrets using **[sops-nix](https://github.com/Mic92/sops-nix) (with yubikey)** via a private repository called `nix-secrets`
- Includes [pre-commit](https://github.com/pre-commit/pre-commit) scripts to make sure flake is correctly setup and ready for publication to a git repository
- Remote building with desktop configurations
- Built-in development shell via `direnv`

# References

- [Runarsf's dotfiles](https://github.com/runarsf/dotfiles) and [imatpot's dotfiles](https://github.com/imatpot/dotfiles) - Custom library and inspiration for more traditional flake layout
- [Llakala's nixos config](https://github.com/llakala/nixos) - Additional libraries for home-manager cli integration and inspiration for integrating more HM stuff into the NixOS-specific configs
- [Mistero77's nix-config](https://github.com/Misterio77/nix-config) and [nix starter configs](https://github.com/Misterio77/nix-starter-configs) - Original inspiration for flake, opinionated settings, overlay/devshell setup, sops-nix setup, and better home-manager/nixos split layout
- [Hlissner's dotfiles](https://github.com/hlissner/dotfiles) - Security hardening configs
- [Baitinq's nixos-config](https://github.com/Baitinq/nixos-config) - Partitioning scripts
- [Theopn's](https://github.com/theopn/dotfiles/tree/main) and [yutkat's dotfiles](https://github.com/yutkat/dotfiles/tree/main) - Wezterm settings
- [Getchoo's flake](https://github.com/getchoo/flake) - Nvidia settings
- [sagikazarmark's nix-config](https://github.com/sagikazarmark/nix-config) - Structure of host configurations
- [archer-65's nix-dotfiles](https://github.com/archer-65/nix-dotfiles) - Structure of host configurations
- [lgug2z Handling Secrets in NixOS Blogpost](https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/#managing-your-own-physical-machines) - Git-crypt implementation for secrets required during flake evaluation
- [Lillian-Violet's NixOS-Configuration](https://github.com/Lillian-Violet/NixOS-Configuration) - some ISO/live-image settings
- [EmergentMind's nix-config](https://github.com/EmergentMind/nix-config/) and [nix-secrets-reference](https://github.com/EmergentMind/nix-secrets-reference) - just file integration and helpful secret tips and nix-secrets + sops-nix deployment inspiration
- [sickle-phin's dots-nix](https://github.com/sickle-phin/dots-nix/) - Extra Nvidia environment variables

# Structure

Here's an overview of the repository's file structure (Generated with `eza --icons=never --tree`):

```
./
├── base/
│   ├── chromium/
│   ├── firefox/
│   ├── stylix/
│   └── ...
├── checks/
├── extra/
│   ├── assets/
│   ├── documentation/
│   ├── homeModules/
│   ├── nixosModules/
│   └── scripts/
├── features/
│   ├── boot/
│   │   ├── disko/
│   │   └── pretty-boot/
│   ├── cli/
│   │   ├── atuin/
│   │   ├── deco/
│   │   │   ├── cava/
│   │   │   └── fastfetch/
│   │   ├── dev/
│   │   ├── misc/
│   │   │   └── topgrade/
│   │   ├── oh-my-posh/
│   │   ├── shell/
│   │   │   ├── fish/
│   │   │   └── zsh/
│   │   ├── multiplexer/
│   │   │   ├── tmux/
│   │   │   └── zellij/
│   │   └── utilities/
│   │       ├── git/
│   │       └── ...
│   ├── desktop/
│   │   └── plasma6/
│   ├── hardware/
│   │   ├── bluetooth/
│   │   ├── hard-accel/
│   │   ├── qmk/
│   │   ├── rgb/
│   │   └── yubikey/
│   ├── programs/
│   │   ├── backup/
│   │   ├── browser/
│   │   │   ├── brave/
│   │   │   └── floorp/
│   │   ├── discord/
│   │   ├── games/
│   │   ├── ghostty/
│   │   ├── keepassxc/
│   │   ├── libvirt/
│   │   ├── music-player/
│   │   ├── neovim/
│   │   └── obs/
│   ├── services/
│   │   ├── gps/
│   │   ├── localsend/
│   │   ├── packaging/
│   │   ├── printing/
│   │   ├── sunshine-server/
│   │   ├── syncthing/
│   │   ├── tailscale/
│   │   └── wivrn/
│   └── theme/
│       ├── catppuccin/
│       └── dracula/
├── hosts/
│   ├── installer/
│   │   ├── config/
│   │   ├── features.nix
│   │   ├── hardware-configuration.nix
│   │   └── hostVars.nix
│   ├── knoxpc/
│   │   ├── config/
│   │   │   ├── services/
│   │   │   │   ├── homepage/
│   │   │   │   └── ...
│   │   │   └── ...
│   │   ├── features.nix
│   │   ├── hardware-configuration.nix
│   │   ├── hostVars.nix
│   │   └── ssh_host_ed25519_key.pub
│   ├── profiles/
│   │   └── home-pc/
│   │       ├── features.nix
│   │       └── ...
│   ├── framenova/
│   │   ├── config/
│   │   │   ├── disko.nix
│   │   │   └── ...
│   │   ├── features.nix
│   │   ├── hardware-configuration.nix
│   │   ├── hostVars.nix
│   │   └── ssh_host_ed25519_key.pub
│   └── ryzennova/
│       ├── config/
│       │   ├── disko.nix
│       │   └── ...
│       ├── features.nix
│       ├── hardware-configuration.nix
│       ├── hostVars.nix
│       └── ssh_host_ed25519_key.pub
├── myLib/
├── overlays/
├── pkgs/
│   └── common/
├── users/
│   ├── nixos/
│   │   └── system.nix
│   └── novaviper/
│       ├── dotfiles/
│       ├── hosts/
│       │   ├── framenova.nix
│       │   ├── knoxpc.nix
│       │   ├── ryzennova.nix
│       ├── profiles/
│       │   └── home-pc/
│       ├── ssh.pub
│       └── system.nix
├── flake.lock
├── flake.nix
├── justfile
├── LICENSE
├── outputs.nix
├── README.md
├── shell.nix
└── statix.toml
```

- `flake.nix`: Entrypoint for host and home configurations. Also exposes a devshell for boostrapping the system (`nix develop` or `nix shell`).
- `myLib`: Custom library functions for various parts of the flake, imported into HomeManager and NixOS
- `hosts`: Configurations for each machine, accessible via `nixos-rebuild --flake`.
  - `profiles`: Templates that when specified for a host, imports a block of features and configs within the folder (Also located in users/USERNAME)
  - `framenova`: Framework 13 - 32GB RAM, AMD Ryzen 7640U, AMD Radeon 760M | KDE Plasma 6
  - `ryzennova`: Primary PC - 32GB RAM, Ryzen 5600G, RTX 2060 6GB | KDE Plasma 6
  - `knoxpc`: Homelab/NAS PC - 1GB RAM, Intel Core i5-8400, Intel UHD Graphics 630 | Headless
  - `installer`: ISO configuration | Nvidia drivers included | KDE Plasma 6
- `users`: Configurations for each user, includes both host OS specific (NixOS or Darwin) and Home Manager configurations. Built together with the `hosts` configurations via `nixos-rebuild --flake` (or the darwin equivalent)
- `extra`: Extra stuff like custom modules and flake documentation
  - `nixosModules`: Custom NixOS modules used throughout the flake (and some being upstreamable)
  - `homeModules`: Custom Home-Manager modules used throughout the flake (and some being upstreamable)
  - `scripts`: Bash/Posix scripts needed for various `precommit` and `just` commands
  - `assets`: Repository assets like images and videos
- `base`: Shared configurations applied to all hosts and users
- `features`: Opt-in configurations/feature flags that one or more users/hosts can use
- `checks`: Flake evaluation tools for ensuring the flake is properly formatted and builds successfully. Also contains git-hooks to ensure the repository is properly setup. Accessible via `nix flake check`
- `overlays`: Patches and version overrides for some packages, applied to all systems and even the devshell. Accessible via `nix build`.
- `pkgs`: Custom nix packages defined similarly to the nixpkgs ones. Also accessible via `nix build`. You can compose these into your own configuration by using my flake&rsquo;s overlay, or consume them through NUR.
- `justfile`: Command recipe file for `just`, contains various helpful commands for the flake
- `shell.nix`: Declaration of nix-shell, used for `nix-shell` and `nix develop`. Used for bootstrapping the system

# Installation/Usage

For installation, check out the installation guide located under [documentation/installation.md](extra/documentation/installation.md)! Check out [documentation/tips.md](extra/documentation/tips.md) for some tips and important information regarding how the entire flake works.

# Tooling and Applications I Use

Main user relevant apps

- kde plasma 6
- neovim
- fish + fzf + oh-my-posh
- brave browser
- keepassxc + gopass
- vesktop
- sops-nix + gpg + ssh-agent + yubikey
- tailscale
- kdeconnect + localsend
- krita
- libreoffice
- ghostty + tmux
- prusa-slicer
- and quite a bit more...

Nix stuff

- Home-Manager
- NixOS and nix, of course

# Final Note

I designed my NixOS flake to be modular and customizable; so feel free to change it up and use it in your own setups!
