{outputs, ...}:
with outputs.lib; {
  options = {
    fullName = mkOption {
      default = "";
      type = types.str;
    };
    emailAddress = mkOption {
      default = "";
      type = types.str;
    };
  };
}
