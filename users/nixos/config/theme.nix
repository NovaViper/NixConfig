{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.plasma = let
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      #splashScreen = "";
    };
  in {
    overrideConfig = true;
    inherit workspace;
  };
}
