{
  config,
  outputs,
  pkgs,
  ...
}:
with outputs.lib; {
  imports = [
    {
      _module.args = {
        fullName = "Nova Leary";
        emailAddress = "coder.nova99@mailbox.org";
      };
    }
  ];

  xdg.configFile = {
    "doom/config.org" = mkDotsSymlink {
      config = config;
      user = config.home.username;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = mkDotsSymlink {
      config = config;
      user = config.home.username;
      source = builtins.toFile "keep" "";
    };
  };
}
