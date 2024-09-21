{
  outputs,
  config,
  pkgs,
  ...
}:
with outputs.lib; {
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
      "PrusaSlicer/printer" = mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "PrusaSlicer/printer";
        recursive = true;
      };
      "PrusaSlicer/print" = mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "PrusaSlicer/print";
        recursive = true;
      };
      "PrusaSlicer/physical_printer" = mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "PrusaSlicer/physical_printer";
        recursive = true;
      };
      "PrusaSlicer/filament" = mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "PrusaSlicer/filament";
        recursive = true;
      };
      "PrusaSlicer/bed_models" = mkDotsSymlink {
        config = config;
        user = config.home.username;
        source = "PrusaSlicer/bed_models";
        recursive = true;
      };
    };
  };

  home.packages = with pkgs; [prusa-slicer];
}
