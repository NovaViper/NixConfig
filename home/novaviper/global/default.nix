{
  inputs,
  outputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = with inputs; [
    ../../common
    ../features/cli
    ../features/emacs
    ../features/age
  ];

  # Enable HTML help page
  manual.html.enable = true;

  # Setup Home-Manager
  home = {
    username = lib.mkDefault "novaviper";
    sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/Documents/NixConfig";
      #CARGO_HOME = "${config.xdg.dataHome}/cargo";
    };
    file."./Pictures/Wallpapers".source = inputs.wallpapers;
  };

  # Enable XDG
  xdg = {
    userDirs.enable = true;
    userDirs.createDirectories = true;
    mimeApps.enable = true;
  };
}
