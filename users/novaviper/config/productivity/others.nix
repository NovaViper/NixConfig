{pkgs, ...}: {
  home.packages = with pkgs; [openscad freecad rpi-imager blisp libreoffice-qt6-fresh keepassxc krita kdePackages.tokodon];
}
