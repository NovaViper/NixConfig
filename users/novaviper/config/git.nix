{config, ...}: let
  userVars = config.userVars;
in {
  hm.programs.git = {
    userName = userVars.username;
    userEmail = userVars.email;
    signing = {
      key = "DEAB6E5298F9C516";
      signByDefault = true;
    };
  };
}
