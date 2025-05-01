{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userEmail = lib.mkDefault (throw "programs.git.userEmail is not set");
    userName = lib.mkDefault (throw "programs.git.userName is not set");
    lfs.enable = true;
    ignores = [
      ".direnv"
      "result"
    ];
  };

  home.packages = with pkgs; [
    git-extras
    tig
  ];

  # Enable git authentication handler for OAuth
  programs.git-credential-oauth.enable = true;
}
