{
  config,
  myLib,
  pkgs,
  ...
}: let
  hm-config = config.hm;
  myself = "novaviper";
in {
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
      config = hm-config;
      user = myself;
      source = "PrusaSlicer/printer";
      recursive = true;
    };
    "PrusaSlicer/print" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "PrusaSlicer/print";
      recursive = true;
    };
    "PrusaSlicer/physical_printer" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "PrusaSlicer/physical_printer";
      recursive = true;
    };
    "PrusaSlicer/filament" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "PrusaSlicer/filament";
      recursive = true;
    };
    "PrusaSlicer/bed_models" = myLib.dots.mkDotsSymlink {
      config = hm-config;
      user = myself;
      source = "PrusaSlicer/bed_models";
      recursive = true;
    };
  };

  hm.home.packages = with pkgs; [prusa-slicer];
}
