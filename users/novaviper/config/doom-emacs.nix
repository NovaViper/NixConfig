{
  config,
  lib,
  ...
}: {
  xdg.configFile = {
    "doom/config.org" = lib.dots.mkDotsSymlink {
      inherit config;
      user = config.home.username;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = lib.dots.mkDotsSymlink {
      inherit config;
      user = config.home.username;
      source = builtins.toFile "keep" "";
    };
  };
}
