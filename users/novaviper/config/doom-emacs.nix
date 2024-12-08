{
  config,
  myLib,
  ...
}: let
  hm-config = config.hm;
in {
  create.configFile = {
    "doom/config.org" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = builtins.toFile "keep" "";
    };
  };
}
