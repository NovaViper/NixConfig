{
  config,
  lib,
  pkgs,
  ...
}:
{
  hm.programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings.user = {
      email = lib.mkDefault (throw "programs.git.user.email is not set");
      name = lib.mkDefault (throw "programs.git.user.name is not set");
    };
    lfs.enable = true;
    ignores = [
      ".direnv"
      "result"
    ];
  };

  hm.home.packages = with pkgs; [
    git-extras
    gh
    tig
    lazygit
  ];

  # Enable git authentication handler for OAuth
  hm.programs.git-credential-oauth.enable = true;
}
