# Shamelessly stolen from https://github.com/jechton/nixos/blob/575307e924c12b01f52bed854d7432497d381b72/modules/home/desktop/niri/_lib.nix
{ lib }:
rec {
  # niri's official home-manager module renders `settings` as raw KDL: repeated
  # sibling nodes (multiple `window-rule { ... }` blocks, `match` lines, etc.)
  # have to go through a `_children` list since a Nix attrset can't hold the
  # same key twice, and node properties go through `_props`. These helpers
  # keep that plumbing out of the files that actually declare config.

  # Wrap a list of `{ <key> = ...; }` node values as KDL children.
  mkNodes = key: items: map (item: { ${key} = item; }) items;

  # Column width presets. niri already accounts for gaps in `proportion`, so
  # complementary fractions tile the working area exactly. Truncated decimals
  # like 0.33333 / 0.66667 do not: their rounded pixel widths are not exact
  # complements, leaving a residual that makes the view nudge ("jiggle") when
  # focus moves between two tiled columns. Full-precision fractions avoid it.
  columnWidths = {
    third = 1.0 / 3.0;
    half = 1.0 / 2.0;
    twoThirds = 2.0 / 3.0;
    full = 1.0;
  };

  # `matches = [ { app-id = "..."; } ... ];` -> repeated `match` child nodes.
  mkMatches =
    matchKey: matches:
    lib.optionalAttrs (matches != [ ]) {
      _children = map (m: { ${matchKey}._props = m; }) matches;
    };

  # A window-rule/layer-rule: pulls `matches` out into `match` child nodes and
  # keeps the rest of the attrs (properties) as-is.
  mkRule =
    {
      matches ? [ ],
      ...
    }@rule:
    (mkMatches "match" matches) // (removeAttrs rule [ "matches" ]);

  # Bind helpers: compose a bind's action with optional overlay title/props
  # without spelling out `_props` at every call site.
  mergeProps = bindAttrs: props: bindAttrs // { _props = (bindAttrs._props or { }) // props; };
  withTitle = title: bindAttrs: mergeProps bindAttrs { hotkey-overlay-title = title; };
  hiddenBind = bindAttrs: mergeProps bindAttrs { hotkey-overlay-title = null; };
  withProps = mergeProps;
  noArg = action: { ${action} = { }; };
  withArg = action: value: { ${action} = value; };
  spawn = command: { spawn = command; };
}
