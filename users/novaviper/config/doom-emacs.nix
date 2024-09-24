{
  config,
  outputs,
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
      inherit config;
      user = config.home.username;
      source = "doom/config.org";
    };
    "doom/snippets/.keep" = mkDotsSymlink {
      inherit config;
      user = config.home.username;
      source = builtins.toFile "keep" "";
    };
  };
}
