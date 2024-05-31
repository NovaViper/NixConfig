{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "plasma-panel-spacer-extended";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "plasma-panel-spacer-extended";
    rev = "v${version}";
    hash = "sha256-cZcEDcD+uTOTal6MoXARZ9wXlW7H+DfC3Nfy+5SR9hY=";
  };

  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids/luisbocanegra.panelspacer.extended
    cp -r $src/package/* $out/share/plasma/plasmoids/luisbocanegra.panelspacer.extended
  '';

  meta = with lib; {
    description = "Spacer with Mouse gestures for the KDE Plasma Panel featuring Latte Dock/Gnome/Unity drag window gesture. Run any shortcut, command, application or URL/file with up to ten configurable mouse actions";
    homepage = "https://github.com/luisbocanegra/plasma-panel-spacer-extended";
    changelog = "https://github.com/luisbocanegra/plasma-panel-spacer-extended/blob/${src.rev}/CHANGELOG.md";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [];
    mainProgram = "plasma-panel-spacer-extended";
    platforms = platforms.all;
  };
}
