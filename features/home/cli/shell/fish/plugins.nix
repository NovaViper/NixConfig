{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.fish.plugins = [
    {
      name = "autopair";
      inherit (pkgs.fishPlugins.autopair) src;
    }
    {
      name = "sponge";
      inherit (pkgs.fishPlugins.sponge) src;
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
