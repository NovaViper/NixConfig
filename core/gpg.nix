{
  lib,
  pkgs,
  ...
}:
{
  programs.gnupg.agent.enable = true;

  environment.systemPackages = with pkgs; [ gnupg ];

  home-manager.sharedModules = lib.singleton {
    # Make gpg use pinentry
    services.gpg-agent = {
      enable = true;
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };

    programs.gpg.enable = true;

    programs.gpg.settings = {
      trust-model = "tofu+pgp";
      default-recipient-self = true;
    };
  };
}
