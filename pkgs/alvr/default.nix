{ lib, appimageTools, fetchurl, }:
let
  pname = "alvr";
  version = "20.5.0";
  src = fetchurl {
    url =
      "https://github.com/alvr-org/ALVR/releases/download/v${version}/ALVR-x86_64.AppImage";
    hash = "sha256-shA93fK/F+PNRv+DCTfvN+tm0w/sj/yPEYc5ms2vHRk=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}

    install -Dm444 ${appimageContents}/alvr.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/alvr.desktop \
      --replace 'Exec=alvr_dashboard' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Stream VR games from your PC to your headset via Wi-Fi";
    homepage = "https://github.com/alvr-org/ALVR/";
    changelog = "https://github.com/alvr-org/ALVR/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "alvr";
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
