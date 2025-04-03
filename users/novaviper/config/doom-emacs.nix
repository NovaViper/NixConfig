{
  config,
  myLib,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
in {
  hm.xdg.configFile = {
    "doom/config.org" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = builtins.toFile "keep" "";
    };
  };
}
