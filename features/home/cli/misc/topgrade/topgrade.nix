{
  config,
  lib,
  myLib,
  ...
}: {
  programs.topgrade.enable = true;
  programs.topgrade.settings = {
    misc = {
      pre_sudo = true;
      cleanup = true;
      skip_notify = false;
      display_time = true;
      set_title = true;
    };
    linux = {
      nix_arguments = "--flake ${myLib.flakePath config}";
      home_manager_arguments = ["--flake" "${myLib.flakePath config}"];
    };
  };
}
