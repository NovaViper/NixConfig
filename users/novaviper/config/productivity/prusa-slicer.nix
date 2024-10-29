{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  xdg = {
    mimeApps = {
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

    configFile = {
      "PrusaSlicer/printer" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "PrusaSlicer/printer";
        recursive = true;
      };
      "PrusaSlicer/print" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "PrusaSlicer/print";
        recursive = true;
      };
      "PrusaSlicer/physical_printer" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "PrusaSlicer/physical_printer";
        recursive = true;
      };
      "PrusaSlicer/filament" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "PrusaSlicer/filament";
        recursive = true;
      };
      "PrusaSlicer/bed_models" = dots.mkDotsSymlink {
        inherit config;
        user = config.home.username;
        source = "PrusaSlicer/bed_models";
        recursive = true;
      };
    };
  };

  home.packages = with pkgs; [prusa-slicer];
}
