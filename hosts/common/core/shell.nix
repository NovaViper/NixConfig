{
  lib,
  config,
  ...
}: {
  # Most here is borrowed from https://github.com/Lubsch/nixos-config/blob/main/nixos/common/zsh.nix
  programs.zsh = lib.mkIf (config.home-manager.users != {}) {
    enable = true;
    histFile = "$HOME/.config/zsh/.zsh_history";
  };

  environment = lib.mkIf (config.home-manager.users != {}) {
    etc."zshenv".text = ''export ZDOTDIR="$HOME"/.config/zsh''; # Source zshenv without ~/.zshenv
    pathsToLink = ["/share/zsh"]; # Make zsh-completions work
  };

  home-manager.sharedModules = [
    {
      home.file.".zshenv".enable = false;
    }
  ];
}
