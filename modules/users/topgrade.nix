{
  config,
  outputs,
  ...
}:
outputs.lib.mkModule config "topgrade" {
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        pre_sudo = true;
        cleanup = true;
        skip_notify = false;
        display_time = true;
        set_title = true;
      };
      linux = {
        nix_arguments = "--flake ${outputs.lib.flakePath config}";
        home_manager_arguments = ["--flake" "${outputs.lib.flakePath config}"];
      };
    };
  };
}
