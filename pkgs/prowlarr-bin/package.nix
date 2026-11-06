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

# Use the same loader and library wrapper as the working Lidarr package.
stdenv.mkDerivation (finalAttrs: {
  pname = "prowlarr";
  version = "2.7.0.5723";

  src = fetchurl {
    url = "https://github.com/Prowlarr/Prowlarr/releases/download/v${finalAttrs.version}/Prowlarr.master.${finalAttrs.version}.linux-core-x64.tar.gz";
    hash = "sha256-1ly5+0Qqij3tBV1wJ9uaCPUZrLeQjHr+chdap8M3eDw=";
  };

  sourceRoot = "Prowlarr";
  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];

  # Preserve the bundled .NET assemblies.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/prowlarr"
    cp -a . "$out/lib/prowlarr/"
    chmod +x "$out/lib/prowlarr/Prowlarr"
    find "$out/lib/prowlarr" -type f -print0 |
      while IFS= read -r -d "" file; do
        if patchelf --print-interpreter "$file" >/dev/null 2>&1; then
          patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" "$file"
        fi
      done
    makeWrapper "$out/lib/prowlarr/Prowlarr" "$out/bin/Prowlarr" \
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
    description = "Indexer manager/proxy for torrent trackers and Usenet indexers";
    homepage = "https://prowlarr.com/";
    changelog = "https://github.com/Prowlarr/Prowlarr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "Prowlarr";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
