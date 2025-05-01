{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    mkMerge
    ;
  cfg = config.features;
  mkFeature =
    description:
    mkOption {
      type = types.str;
      description = "The chosen ${description}.";
      default = null;
    };

  mkEnumFeature =
    {
      desc,
      opts,
    }:
    mkOption {
      type = types.nullOr (types.enum opts);
      description = "The chosen ${desc}.";
      default = null;
    };

  mkBoolFeature =
    description:
    mkOption {
      type = types.bool;
      default = false;
      description = "Whether ${description} is being used.";
    };
in
{
  options.features = {
    shell = mkFeature "shell, which provides some form of initExtra access";

    prompt = mkFeature "shell prompt";

    abbreviations = mkFeature "provider of abbreviations";

    direnv = mkFeature "program for providing direnv functionality";

    browser = mkFeature "browser";

    terminal = mkFeature "terminal";

    #files = mkFeature "file manager";

    #pdfs = mkFeature "PDF viewer";

    #images = mkFeature "image viewer";

    #videos = mkFeature "video viewer";

    discord = mkFeature "Discord client";

    #music = mkFeature "music player";

    #math = mkFeature "math notes";
  };

  /*
      config = mkMerge [
      {
        assertions = [
          {
            assertion = (cfg.vr != null) -> (cfg.desktop != null);
            message = "There must be a desktop selected via features.desktop in order to use anything related to virutal reality (VR)!";
          }
          {
            assertion = cfg.useWayland -> (cfg.desktop != null);
            message = "There must be a desktop selected via features.desktop in order to use anything related to Wayland!";
          }
        ];
      }
    ];
  */
}
