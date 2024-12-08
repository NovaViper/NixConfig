{
  lib,
  myLib,
  ...
}: let
  internals = {
    # Helper for creating modules
    mkModuleWithOptions = {
      config,
      name,
      moduleConfig,
      default ? false,
      extraOptions ? {},
      extraCondition ? true,
    }: let
      namePathList = lib.splitString "." name;

      modulePath = ["modules"] ++ namePathList;
      enableOptionPath = modulePath ++ ["enable"];

      moduleOptions =
        {
          enable = lib.mkOption {
            inherit default;
            type = lib.types.bool;
            description = "Enable [${name}] module";
          };
        }
        // extraOptions;
    in {
      options = lib.setAttrByPath modulePath moduleOptions;

      config =
        lib.mkIf
        (lib.getAttrFromPath enableOptionPath config && extraCondition)
        moduleConfig;
    };
  };

  exports = {
    # Function for creating modules.NAME modules, with extra options
    mkModule' = config: name: extraOptions: moduleConfig:
      internals.mkModuleWithOptions {inherit config name extraOptions moduleConfig;};

    # Function for creating modules.NAME modules, without extra options
    mkModule = config: name: moduleConfig: exports.mkModule' config name {} moduleConfig;

    # Function for creating modules.NAME modules that are enabled by default, with extra options
    mkEnabledModule' = config: name: extraOptions: moduleConfig:
      internals.mkModuleWithOptions {
        inherit config name extraOptions moduleConfig;
        default = true;
      };

    # Function for creating modules.NAME modules that are enabled by default, without extra options
    mkEnabledModule = config: name: moduleConfig:
      exports.mkEnabledModule' config name {} moduleConfig;

    mkDesktopModule' = config: name: extraOptions: moduleConfig:
      internals.mkModuleWithOptions {
        inherit config name extraOptions moduleConfig;
        extraCondition = myLib.conds.runsDesktop config;
      };

    mkDesktopModule = config: name: moduleConfig:
      exports.mkDesktopModule' config name {} moduleConfig;
  };
in
  exports
