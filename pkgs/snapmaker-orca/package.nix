{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "snapmaker-orca";
  version = "2.4.0";

  src = fetchurl {
    url = "https://github.com/Snapmaker/OrcaSlicer/releases/download/v${version}/Snapmaker_Orca_Linux_AppImage_Ubuntu2404_V${version}.AppImage";
    hash = "sha256-QQM4Vlur9ZZA0IL645wcMnA065iIO1l9dA6qWHyJt14=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The AppImage doesn't bundle WebKitGTK and refuses to start without it.
  extraPkgs =
    pkgs: with pkgs; [
      glib-networking
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-good
      webkitgtk_4_1
    ];

  # GIO only searches glib's own store path, so WebKit has no TLS backend
  # without GIO_EXTRA_MODULES. SSL_CERT_FILE stops it asking on first launch
  # whether to use the CA bundle it found.
  profile = ''
    export GIO_EXTRA_MODULES="/usr/lib64/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}"
    export SSL_CERT_FILE="''${SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}"
  '';

  extraInstallCommands = ''
    install -Dm444 -t $out/share/applications ${contents}/usr/share/applications/*.desktop
    substituteInPlace $out/share/applications/*.desktop --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${contents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Snapmaker's fork of OrcaSlicer";
    homepage = "https://github.com/Snapmaker/OrcaSlicer";
    license = lib.licenses.agpl3Only;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
