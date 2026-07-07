{
  config,
  myLib,
  ...
}:
{
  hm.programs.git.signing = {
    format = "openpgp";
    signByDefault = true;
    key = "E5E6D90A268AC09D";
  };

  hm.programs.git.settings = {
    user = {
      name = "NovaViper";
      email = config.vars.user.email;
    };
  };
}
