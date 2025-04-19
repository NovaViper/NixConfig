{
  config,
  myLib,
  ...
}: {
  programs.git = {
    userName = "NovaViper";
    userEmail = myLib.utils.getUserVars "email" config;
    signing = {
      key = "E5E6D90A268AC09D";
      signByDefault = true;
    };
  };
}
