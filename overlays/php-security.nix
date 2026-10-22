# TODO: Keep until https://github.com/NixOS/nixpkgs/pull/576853 is available
# in unstable
# Taken from https://gbyte.dev/blog/nixos-quick-fix-php-cve-2026-109618-and-cve-2026-109619
_final: prev:
builtins.mapAttrs
  (
    name: attrs:
    if prev.lib.versionOlder prev.${name}.version attrs.version then
      prev.${name}.overrideAttrs (_: {
        inherit (attrs) version;
        src =
          let
            archive = prev.fetchurl {
              url = "https://www.php.net/distributions/php-${attrs.version}.tar.bz2";
              inherit (attrs) hash;
            };
          in
          # Drop the three OOM regression tests as in the linked example.
          prev.runCommand "php-${attrs.version}-src" { } ''
            mkdir -p "$out"
            tar -xf ${archive} -C "$out" --strip-components=1
            rm -f "$out"/ext/filter/tests/oom_filter_input.phpt \
                  "$out"/ext/filter/tests/oom_filter_input_array.phpt \
                  "$out"/ext/filter/tests/oom_filter_default_encoded.phpt
          '';
      })
    else
      prev.${name}
  )
  {
    php82 = {
      version = "8.2.35";
      hash = "sha256:0f43efd1ac24d4f90002c8d4d570bf4c4d59fa14313bf270aae8cf04d9dfdef3";
    };
    php83 = {
      version = "8.3.36";
      hash = "sha256-RvS0XjaI7SsYGQFae1MsFbUcwFW907E/0A3f7r7tzV8=";
    };
    php84 = {
      version = "8.4.27";
      hash = "sha256-slMKh3xyL0sIyeF0owywi6wrfhkD7m6eMV8KqfX4LCQ=";
    };
    php85 = {
      version = "8.5.12";
      hash = "sha256-/7YO3EN87WO1E35JhNs3moERxQBJxxFRDYuVgnfvwag=";
    };
  }
