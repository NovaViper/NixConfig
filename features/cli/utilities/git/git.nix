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
    userEmail = lib.mkDefault (throw "programs.git.userEmail is not set");
    userName = lib.mkDefault (throw "programs.git.userName is not set");
    lfs.enable = true;
    ignores = [
      ".direnv"
      "result"
    ];
  };

  hm.home.packages = with pkgs; [
    git-extras
    tig
  ];

  # Enable git authentication handler for OAuth
  hm.programs.git-credential-oauth.enable = true;
}
