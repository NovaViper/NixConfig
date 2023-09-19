{ config, lib, pkgs, ... }:

{
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        pre_sudo = true;
        cleanup = true;
        skip_notify = false;
      };
      linux = {
        nix_arguments = "--flake ${config.home.sessionVariables.FLAKE}";
        home_manager_arguments =
          [ "--flake" "${config.home.sessionVariables.FLAKE}" ];
      };
      pre_commands = lib.mkIf (config.programs.emacs.enable) {
        "Discard org-bable changes for upgrade" =
          "git -C ~/.config/emacs reset --hard";
      };
      post_commands = lib.mkIf (config.programs.emacs.enable) {
        "Make Doom Emacs org-bable work again" = ''
          sed -i -e "/'org-babel-tangle-collect-blocks/,+1d" ~/.config/emacs/bin/org-tangle'';
      };
      commands = {
        "Run garbage collection on Nix store" = "nix-collect-garbage";
      };
    };
  };
}
