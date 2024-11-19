{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: let
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."${username}-password".path;
in {
  variables.user = {
    fullName = "Nova Leary";
    emailAddress = "coder.nova99@mailbox.org";
  };
  variables.userIdentityPaths = lib.secrets.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"];

  users.users.${username} = {
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "libvirtd"
      "scanner"
      "i2c"
      "git"
      "gamemode"
    ];
    openssh.authorizedKeys.keys = lib.singleton "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICkow+KpToZkMbhpqTztf0Hz/OWP/lWPCv47QNtZc6TaAAAADnNzaDpuaXhidWlsZGVy";
    hashedPasswordFile = agenixHashedPasswordFile;
  };

  # Import specific stuff for the user
  home-manager.users.${username} = import ../../users/${username}/${config.networking.hostName}.nix;

  time.timeZone = lib.mkForce "America/Chicago";

  # User Secrets
  age.secrets."${username}-password" = lib.secrets.mkSecretFile {
    user = username;
    source = "passwd.age";
  };

  # Make CAPS LOCK become CTRL key for Emacs
  services.xserver.xkb.options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";

  programs.localsend.enable = true;

  # Modules for system live under ../../modules/system
  modules = lib.utils.enable [
    # Terminal
    "zsh"

    # Hardware
    "yubikey"

    # Services
    "syncthing"
  ];

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    image = "${inputs.wallpapers}/purple-mountains-ai.png";
    override = {
      scheme = "BetterDracula";
      base00 = "282a36";
      base01 = "363447";
      base02 = "44475a";
      base03 = "6272a4";
      base04 = "9ea8c7";
      base05 = "f8f8f2";
      base06 = "f0f1f4";
      base07 = "ffffff";
      base08 = "ff5555";
      base09 = "ffb86c";
      base0A = "f1fa8c";
      base0B = "50fa7b";
      base0C = "8be9fd";
      base0D = "80bfff";
      base0E = "ff79c6";
      base0F = "bd93f9";
    };
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors-white";
      size = 24;
    };
    fonts = let
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "NotoSans Nerd Font";
      };
      serif = sansSerif;
      monospace = {
        package = pkgs.nerdfonts;
        name = "0xProto Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 11;
      };
    in {inherit sansSerif serif monospace emoji sizes;};
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 1.0;
      terminal = 1.0;
    };
  };

  # Modules for users live under ../../modules/home
  hm.variables = {
    defaultTerminal = "kitty";
    defaultBrowser = "floorp";
    defaultTextEditor = "doom-emacs";
  };

  hm.home.packages = with pkgs; [openscad freecad rpi-imager blisp libreoffice-qt6-fresh keepassxc krita kdePackages.tokodon smassh digikam];

  hm.stylix.targets = lib.mkForce {
    # Enable 256 colors for kitty
    kitty.variant256Colors = true;
    # Causes some mismatched colors with Dracula-tmux theme
    tmux.enable = false;
    # Disable stylix's KDE module, very broken currently
    kde.enable = false;
    emacs.enable = false;
  };

  hm.age.secrets."borg_token" = lib.secrets.mkSecretFile {
    user = username;
    source = "borg.age";
    destination = "${config.hm.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
  };
  hm.modules = lib.utils.enable [
    # Core
    "git"
    "doom-emacs"
    "password-store"

    # Terminal Utils
    "shell-utils"
    "nix"
    "cava"
    "tmux"
    "bat"
    "btop"
    "fastfetch"
    "topgrade"

    # Development Environment
    "latex"
    "lua"
    "markdown"
    "python"
    "rust"

    # Applications
    #"vivaldi"
    "jellyfin-player"
    "borg"
    "discord"
  ];
}
