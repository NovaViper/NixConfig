{
  config,
  myLib,
  lib,
  pkgs,
  ...
}:
let
  orcaSlicer = pkgs.inputs.nixpkgs-orca-slicer.orca-slicer;
  desktopFile = "com.orcaslicer.OrcaSlicer.desktop";
in
{
  hm.xdg.dataFile."applications/${desktopFile}" =
    lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers)
      {
        source = pkgs.runCommand desktopFile { } ''
          substitute ${orcaSlicer}/share/applications/${desktopFile} "$out" \
            --replace-fail 'Exec=orca-slicer' 'Exec=env WEBKIT_DISABLE_DMABUF_RENDERER=1 orca-slicer'
        '';
      };

  hm.xdg.mimeApps =
    let
      profiles = {
        "model/step" = desktopFile;
        "x-scheme-handler/orcaslicer" = desktopFile;
        "x-scheme-handler/bambustudio" = desktopFile; # makerworld
        "x-scheme-handler/prusaslicer" = desktopFile; # printables
      };
    in
    {
      associations.added = profiles;
      defaultApplications = profiles;
    };

  # hm.xdg.configFile =
  #   let
  #     dots =
  #       source:
  #       myLib.dots.mkDotsSymlink {
  #         inherit config source;
  #         recursive = true;
  #       };
  #   in
  #   {
  #     "OrcaSlicer/printer" = dots "OrcaSlicer/printer";
  #     "OrcaSlicer/print" = dots "OrcaSlicer/print";
  #     "OrcaSlicer/physical_printer" = dots "OrcaSlicer/physical_printer";
  #     "OrcaSlicer/filament" = dots "OrcaSlicer/filament";
  #     "OrcaSlicer/bed_models" = dots "OrcaSlicer/bed_models";
  #   };

  hm.home.packages = [
    orcaSlicer
  ]
  ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.snapmaker-orca) pkgs.snapmaker-orca;
}
