{
  config,
  lib,
  pkgs,
  ...
}: {
  # Much better ls replacement
  programs.eza = {
    enable = true;
    git = true;
    icons = true;
    extraOptions = ["--color=always" "--group-directories-first" "--classify"];
  };
}
