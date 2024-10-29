{lib, ...}: {
  options = {
    nukeFiles = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
      description = "Files to nuke to pave the way for Home Manager. Requires full path to file or ~/ path";
    };
  };
}
