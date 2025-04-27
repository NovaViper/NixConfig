{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.fish.plugins = [
    {
      name = "autopair";
      inherit (pkgs.fishPlugins.autopair) src;
    }
    {
      name = "fzf.fish";
      inherit (pkgs.fishPlugins.fzf-fish) src;
    }
    {
      name = "pufferfish";
      inherit (pkgs.fishPlugins.puffer) src;
    }
    {
      name = "done";
      inherit (pkgs.fishPlugins.done) src;
    }
  ];
}
