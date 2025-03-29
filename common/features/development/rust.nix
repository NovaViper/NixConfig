{
  config,
  pkgs,
  ...
}: {
  hm.home.packages = with pkgs; [rustup];

  hm.home.sessionVariables.RUSTUP_HOME = "${config.hm.xdg.dataHome}/rustup";
}
