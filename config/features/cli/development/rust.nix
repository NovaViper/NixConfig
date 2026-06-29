{
  config,
  pkgs,
  ...
}:
let
  hm-config = config.hm;
in
{
  hm.home.packages = with pkgs; [ rustup ];

  hm.home.sessionVariables.RUSTUP_HOME = "${hm-config.xdg.dataHome}/rustup";
}
