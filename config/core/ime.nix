{ pkgs, ... }: {

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      kdePackages.fcitx5-configtool
      catppuccin-fcitx5
      fcitx5-gtk
      fcitx5-lua
      fcitx5-table-extra
      fcitx5-table-other
    ];
  };
}
