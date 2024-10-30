_: let
  exports = {
    # Pass unicode symbols correctly
    ucode = code: builtins.fromJSON "\"\\u${code}\"";

    mkSeg' = {
      type,
      style,
      opts,
    }:
      {inherit type style;} // opts;

    # Make a plain segment
    mkSeg = type: opts:
      exports.mkSeg' {
        inherit type opts;
        style = "plain";
      };

    # Make a Powerline segment that's on the corner of the screen
    mkPowerlineSegCorner = type: opts:
      exports.mkSeg' {
        inherit type opts;
        style = "powerline";
      };

    # Make a powerline segment that has the arrows (for left side)
    mkPowerlineSeg = type: opts:
      exports.mkSeg' {
        inherit type;
        style = "powerline";
        opts = opts // {powerline_symbol = "${exports.ucode "E0B0"}";};
      };
    # Make a diamond segment that has the arrow (for right side)
    mkDiamondSeg = type: opts:
      exports.mkSeg' {
        inherit type;
        style = "diamond";
        opts = opts // {leading_diamond = "${exports.ucode "E0B2"}";};
      };
  };
in
  exports
