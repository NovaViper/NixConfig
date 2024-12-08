{
  config,
  myLib,
  pkgs,
  ...
}:
myLib.utilMods.mkModule config "rust" {
  home.packages = with pkgs; [rustup];

  home.sessionVariables.RUSTUP_HOME = "${config.hm.xdg.dataHome}/rustup";
}
