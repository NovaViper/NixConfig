{
  config,
  myLib,
  ...
}: let
  myself = "novaviper";
in {
  xdg.configFile = {
    "doom/config.org" = myLib.dots.mkDotsSymlink {
      config = config;
      user = myself;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = myLib.dots.mkDotsSymlink {
      config = config;
      user = myself;
      source = builtins.toFile "keep" "";
    };
  };
}
