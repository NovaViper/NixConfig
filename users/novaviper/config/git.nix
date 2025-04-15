{
  config,
  myLib,
  ...
}: {
  programs.git = {
    userName = "NovaViper";
    userEmail = myLib.utils.getUserVars "email" config;
    signing = {
      key = "DEAB6E5298F9C516";
      signByDefault = true;
    };
  };
}
