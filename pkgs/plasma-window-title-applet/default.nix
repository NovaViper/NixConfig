{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "plasma6-window-title-applet";
  version = "unstable-2024-04-11";

  src = fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    rev = "6d6b939bb8138a8b1640cf2f6d395a3030d7bbaa";
    hash = "sha256-dfJcRbUubv3/1PAWCFtNWzc8nyIcgTW39vryFLOOqzs=";
  };

  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
    cp -r $src/metadata.json $src/contents $out/share/plasma/plasmoids/org.kde.windowtitle
  '';

  meta = with lib; {
    description = "Plasma 6 Window Title applet";
    homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    changelog = "https://github.com/dhruv8sh/plasma6-window-title-applet/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [];
    mainProgram = "plasma6-window-title-applet";
    platforms = platforms.all;
  };
}
