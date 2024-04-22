{
  config,
  lib,
  pkgs,
  ...
}: let
  utils = import ../../../lib/utils.nix {inherit config pkgs;};
in {
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
      "PrusaSlicer/printer" = {
        source = utils.linkDots "PrusaSlicer/printer";
        recursive = true;
      };
      "PrusaSlicer/print" = {
        source = utils.linkDots "PrusaSlicer/print";
        recursive = true;
      };
      "PrusaSlicer/physical_printer" = {
        source = utils.linkDots "PrusaSlicer/physical_printer";
        recursive = true;
      };
      "PrusaSlicer/filament" = {
        source = utils.linkDots "PrusaSlicer/filament";
        recursive = true;
      };
      "PrusaSlicer/bed_models" = {
        source = utils.linkDots "PrusaSlicer/bed_models";
        recursive = true;
      };
    };
  };

  home.packages = with pkgs; [prusa-slicer];
}
