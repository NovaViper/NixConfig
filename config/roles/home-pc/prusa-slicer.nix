{
  config,
  myLib,
  pkgs,
  ...
}:
{
  hm.xdg.mimeApps =
    let
      profiles = {
        "model/stl" = "PrusaSlicer.desktop";
        "x-scheme-handler/prusaslicer" = "PrusaSlicerURLProtocol.desktop"; # printables
      };
    in
    {
      associations.added = profiles;
      defaultApplications = profiles;
    };

  hm.xdg.configFile =
    let
      prusaDots =
        source:
        myLib.dots.mkDotsSymlink {
          inherit config source;
          recursive = true;
        };
    in
    {
      "PrusaSlicer/printer" = prusaDots "PrusaSlicer/printer";
      "PrusaSlicer/print" = prusaDots "PrusaSlicer/print";
      "PrusaSlicer/physical_printer" = prusaDots "PrusaSlicer/physical_printer";
      "PrusaSlicer/filament" = prusaDots "PrusaSlicer/filament";
      "PrusaSlicer/bed_models" = prusaDots "PrusaSlicer/bed_models";
    };

  hm.home.packages = with pkgs; [ prusa-slicer ];
}
