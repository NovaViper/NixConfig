{
  config,
  myLib,
  ...
}:
let
  user = "novaviper";
  hm-config = config.hm;
in
{
  hm.xdg.configFile = {
    "doom/config.org" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = builtins.toFile "keep" "";
    };
  };

  hm.home.file.".authinfo.gpg".source = myLib.secrets.getUserSecretPath {
    inherit user;
    path = "authinfo.gpg";
  };
}
