{
  config,
  myLib,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.git.signing = {
    format = "openpgp";
    signByDefault = true;
    key = "E5E6D90A268AC09D";
  };

  hm.programs.git.settings = {
    user = {
      name = "NovaViper";
      email = myLib.utils.getUserVars "email" hm-config;
    };
  };
}
