{
  config,
  lib,
  pkgs,
  ...
}:
{
  hm.programs.plasma =
    let
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        #splashScreen = "";
      };
    in
    {
      overrideConfig = true;
      inherit workspace;
    };
}
