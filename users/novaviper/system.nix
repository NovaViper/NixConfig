{
  config,
  lib,
  myLib,
  pkgs,
  username,
  inputs,
  ...
}: let
  hm-config = config.hm;
  agenixHashedPasswordFile = lib.optionalString (lib.hasAttr "agenix" inputs) config.age.secrets."${username}-password".path;
in {
  variables = {
    defaultTerminal = "kitty";
    defaultBrowser = "floorp";
    defaultTextEditor = "doom-emacs";
    user = {
      fullName = "Nova Leary";
      emailAddress = "coder.nova99@mailbox.org";
    };
    userIdentityPaths = myLib.secrets.mkSecretIdentities ["age-yubikey-identity-a38cb00a-usba.txt"];
  };

  users.users.${username} = {
    useDefaultShell = true; # Use the shell environment module declaration
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

  time.timeZone = lib.mkForce "America/Chicago";

  # User Secrets
  age.secrets."${username}-password" = myLib.secrets.mkSecretFile {
    user = username;
    source = "passwd.age";
  };

  # Make CAPS LOCK become CTRL key for Emacs
  services.xserver.xkb.options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";

  programs.localsend.enable = true;

  modules = myLib.utils.enable [
    # Core
    "git"
    "doom-emacs"
    "password-store"

    # Shell
    "zsh"

    # Hardware
    "yubikey"

    # Services
    "syncthing"

    # Terminal Utils
    "shell-utils"
    "nix"
    #"cava"
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

  home.packages = with pkgs; [openscad freecad rpi-imager blisp libreoffice-qt6-fresh keepassxc krita kdePackages.tokodon smassh tmatrix];

  hm.age.secrets."borg_token" = myLib.secrets.mkSecretFile {
    user = username;
    source = "borg.age";
    destination = "${hm-config.xdg.configHome}/borg/keys/srv_dev_disk_by_uuid_5aaed6a3_d2c7_4623_b121_5ebb8d37d930_Backups";
  };
}
