{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  makeWrapper,
  zlib,
  icu,
  openssl,
}:

# nixpkgs still builds 3.1.0 from source. This is the official 3.1.6
# release Lidarr is asking for. The binary ships its own .NET runtime
# and needs NixOS's loader plus ICU, OpenSSL, and zlib.
stdenv.mkDerivation (finalAttrs: {
  pname = "lidarr";
  version = "3.1.6.5079";

  src = fetchurl {
    url = "https://github.com/Lidarr/Lidarr/releases/download/v${finalAttrs.version}/Lidarr.master.${finalAttrs.version}.linux-core-x64.tar.gz";
    hash = "sha256-/tFsWPXeeXvpVegwo6k5lPAgwdjWD1pssGHXZH1FuLw=";
  };

  sourceRoot = "Lidarr";

  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];

  # The .NET assemblies are PE files. strip shortens them and CoreCLR
  # then refuses to load them.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lidarr
    cp -a . $out/lib/lidarr/
    chmod +x $out/lib/lidarr/Lidarr $out/lib/lidarr/fpcalc
    find $out/lib/lidarr -type f -print0 |
      while IFS= read -r -d "" file; do
        if patchelf --print-interpreter "$file" >/dev/null 2>&1; then
          patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" "$file"
        fi
      done
    makeWrapper $out/lib/lidarr/Lidarr $out/bin/Lidarr \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          stdenv.cc.cc.lib
          zlib
          icu
          openssl.out
        ]
      }
    runHook postInstall
  '';

  meta = {
    description = "Usenet/BitTorrent music downloader";
    homepage = "https://lidarr.audio";
    license = lib.licenses.gpl3Only;
    mainProgram = "Lidarr";
    platforms = [ "x86_64-linux" ];
  };
})
