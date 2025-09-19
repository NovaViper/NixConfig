{
  self,
  final,
  prev,
}:
let
  pname = "brave";
  version = "1.82.170";

  # fill in hashes as used
  allArchives = {
    aarch64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_arm64.deb";
      hash = "sha256-mIz3ntO2NQX0NdNZ4puk+WPynm/ylqz40YgHaZ1fSQU=";
    };
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
      hash = "sha256-6pJLrMmFK5jlLk+y5YEyBzpv7JVGlzDZsoS5IRcXHc0=";
    };
    aarch64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-v${version}-darwin-arm64.zip";
      hash = "sha256-hfXtVhcI7bxNYWtlKxUduBSxHDnItaktIVkHz3azys8=";
    };
    x86_64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-v${version}-darwin-x64.zip";
      hash = "sha256-QyZ0J3/+hkHnkSZSTYt2J2PmOJ60xZVLIaHRjWLQfk4=";
    };
  };

  archive =
    if builtins.hasAttr prev.stdenv.system allArchives then
      allArchives.${prev.stdenv.system}
    else
      throw "Unsupported platform: ${prev.stdenv.system}";

in
prev.brave.overrideAttrs (oldAttrs: {
  pname = pname;
  version = version;
  src = prev.fetchurl (
    archive
    // {
      inherit (archive) url;
    }
  );
  meta = oldAttrs.meta // {
    changelog =
      "https://github.com/brave/brave-browser/blob/master/CHANGELOG_DESKTOP.md#"
      + prev.lib.replaceStrings [ "." ] [ "" ] version;
  };
})
