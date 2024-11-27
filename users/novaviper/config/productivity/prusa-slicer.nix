{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  hm-config = config.hm;
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

  create.configFile = {
    "PrusaSlicer/printer" = dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "PrusaSlicer/printer";
      recursive = true;
    };
    "PrusaSlicer/print" = dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "PrusaSlicer/print";
      recursive = true;
    };
    "PrusaSlicer/physical_printer" = dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "PrusaSlicer/physical_printer";
      recursive = true;
    };
    "PrusaSlicer/filament" = dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "PrusaSlicer/filament";
      recursive = true;
    };
    "PrusaSlicer/bed_models" = dots.mkDotsSymlink {
      config = hm-config;
      user = hm-config.home.username;
      source = "PrusaSlicer/bed_models";
      recursive = true;
    };
  };

  home.packages = with pkgs; [prusa-slicer];
}
