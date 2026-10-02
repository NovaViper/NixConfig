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
        "model/step" = "OrcaSlicer.desktop";
        "x-scheme-handler/orcaslicer" = "OrcaSlicer.desktop";
        "x-scheme-handler/bambustudio" = "OrcaSlicer.desktop"; # makerworld
        "x-scheme-handler/prusaslicer" = "OrcaSlicer.desktop"; # printables
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

  hm.home.packages = with pkgs; [ orca-slicer ];
}
