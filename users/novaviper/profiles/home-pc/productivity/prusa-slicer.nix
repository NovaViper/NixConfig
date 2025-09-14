{
  config,
  myLib,
  pkgs,
  ...
}:
let
  user = "novaviper";
  hm-config = config.hm;
in
{
  hm.xdg.mimeApps = {
    associations = {
      added = {
        "x-scheme-handler/prusaslicer" = "PrusaSlicerURLProtocol.desktop";
        "model/stl" = "PrusaSlicer.desktop";
      };
    };
    defaultApplications = {
      "x-scheme-handler/prusaslicer" = "PrusaSlicerURLProtocol.desktop";
      "model/stl" = "PrusaSlicer.desktop";
    };
  };

  hm.xdg.configFile = {
    "PrusaSlicer/printer" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = "PrusaSlicer/printer";
      recursive = true;
    };
    "PrusaSlicer/print" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = "PrusaSlicer/print";
      recursive = true;
    };
    "PrusaSlicer/physical_printer" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = "PrusaSlicer/physical_printer";
      recursive = true;
    };
    "PrusaSlicer/filament" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = "PrusaSlicer/filament";
      recursive = true;
    };
    "PrusaSlicer/bed_models" = myLib.dots.mkDotsSymlink {
      inherit user;
      config = hm-config;
      source = "PrusaSlicer/bed_models";
      recursive = true;
    };
  };

  hm.home.packages = with pkgs; [ prusa-slicer ];
}
