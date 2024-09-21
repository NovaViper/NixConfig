{
  config,
  osConfig,
  inputs,
  outputs,
  system,
  hostname,
  name,
  pkgs,
  ...
}:
outputs.lib.mkFor system hostname {
  common = {
    imports =
      outputs.lib.umport {path = ../../modules/users;}
      ++ outputs.lib.umport {path = ./config;};

    defaultTerminal = "konsole";
    defaultBrowser = "firefox";
    modules = outputs.lib.enable [
      "git"
      "ssh"
      "gpg"
      "yubikey"
      "age"

      # Terminal
      "zsh"
      "nix"
      "bat"
      "btop"
      "fastfetch"
    ];
  };

  systems.linux = {
    isDesktop = true;
    modules = outputs.lib.enable [
      # Desktop
      "plasma6"
    ];
    nixos.users.users."${name}" = {
      isNormalUser = true;
      shell = pkgs.zsh;
    };
  };
}
