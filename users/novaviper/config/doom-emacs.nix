{
  config,
  myLib,
  ...
}: let
  user = "novaviper";
in {
  xdg.configFile = {
    "doom/config.org" = myLib.dots.mkDotsSymlink {
      inherit config user;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = myLib.dots.mkDotsSymlink {
      inherit config user;
      source = builtins.toFile "keep" "";
    };
  };

  home.file.".authinfo.gpg".source = myLib.secrets.getUserSecretPath {
    inherit user;
    path = "authinfo.gpg";
  };
}
