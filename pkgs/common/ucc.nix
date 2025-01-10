{
  autoconf,
  automake,
  config,
  cudaPackages,
  fetchFromGitHub,
  lib,
  libtool,
  stdenv,
  ucx,
  # Configuration options
  enableAvx ? stdenv.hostPlatform.avxSupport,
  enableCuda ? config.cudaSupport,
  enableSse41 ? stdenv.hostPlatform.sse4_1Support,
  enableSse42 ? stdenv.hostPlatform.sse4_2Support,
} @ inputs: let
  inherit (lib.attrsets) getLib;
  inherit (lib.lists) optionals;
  inherit (lib.strings) concatStringsSep optionalString;

  inherit
    (cudaPackages)
    cuda_cccl
    cuda_cudart
    cuda_nvcc
    cuda_nvml_dev
    cudaFlags
    nccl
    ;

  stdenv = throw "Use effectiveStdenv instead";
  effectiveStdenv =
    if enableCuda
    then cudaPackages.backendStdenv
    else inputs.stdenv;
in
  effectiveStdenv.mkDerivation (finalAttrs: {
    __structuredAttrs = true;
    # TODO: The M4 file requires a unified CUDA installation and doesn't support splayed outputs:
    # https://github.com/openucx/ucc/blob/0c0fc21559835044ab107199e334f7157d6a0d3d/config/m4/cuda.m4
    # Enabling strictDeps will break the build when CUDA is enabled.
    strictDeps = false;

    pname = "ucc";
    version = "1.3.0";

    src = fetchFromGitHub {
      owner = "openucx";
      repo = "ucc";
      tag = "v${finalAttrs.version}";
      hash = "sha256-xcJLYktkxNK2ewWRgm8zH/dMaIoI+9JexuswXi7MpAU=";
    };

    outputs = [
      "out"
      "dev"
    ];

    enableParallelBuilding = true;

    postPatch = ''
      for comp in $(find src/components -name Makefile.am); do
        if ! grep -q "/bin/bash" "$comp"; then
          continue
        fi
        substituteInPlace "$comp" \
          --replace-fail \
            "/bin/bash" \
            "${effectiveStdenv.shell}"
      done
    '';

    nativeBuildInputs =
      [
        autoconf
        automake
        libtool
      ]
      ++ optionals enableCuda [cuda_nvcc];

    buildInputs =
      [ucx]
      ++ optionals enableCuda [
        cuda_cccl
        cuda_cudart
        cuda_nvml_dev
        nccl
      ];

    preConfigure =
      # Fake libnvidia-ml.so (the real one is deployed impurely)
      optionalString enableCuda ''
        addToSearchPath LDFLAGS "-L${getLib cuda_nvml_dev}/lib/stubs"
      ''
      # Generate the configure script
      + ''
        ./autogen.sh
      '';

    configureFlags =
      optionals enableSse41 ["--with-sse41"]
      ++ optionals enableSse42 ["--with-sse42"]
      ++ optionals enableAvx ["--with-avx"]
      ++ optionals enableCuda [
        "--with-cuda=${cuda_cudart}"
        "--with-nvcc-gencode=${concatStringsSep " " cudaFlags.gencode}"
      ];

    postInstall = ''
      find "$out/lib/" -name "*.la" -exec rm -f \{} \;

      moveToOutput bin/ucc_info "$dev"
    '';

    meta = with lib; {
      description = "Collective communication operations API";
      mainProgram = "ucc_info";
      license = licenses.bsd3;
      maintainers = [maintainers.markuskowa];
      platforms = platforms.linux;
    };
  })
