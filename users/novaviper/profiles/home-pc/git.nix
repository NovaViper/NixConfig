{
  config,
  myLib,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.programs.git = {
    userName = "NovaViper";
    userEmail = myLib.utils.getUserVars "email" hm-config;
    signing = {
      key = "E5E6D90A268AC09D";
      signByDefault = true;
    };
  };
}
