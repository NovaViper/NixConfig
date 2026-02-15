{
  self,
  final,
  prev,
}:
let
  pname = "brave";
  version = "1.87.188";

  # fill in hashes as used
  allArchives = {
    aarch64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_arm64.deb";
      hash = "sha256-v4q5kXwpdYXzXFzkJDvuBdlvuHYt9Zyj5R3R4Ajivxo=";
    };
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
      hash = "sha256-fQx9UQ7G57q08rIR5rWh6qBGmprcVlv8OTzoK8u/SeI=";
    };
    aarch64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-v${version}-darwin-arm64.zip";
      hash = "sha256-UbH4M9jeT+vfzd/V5y0UQNM6ye4/ejp/4drzsUOvpIA=";
    };
    x86_64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-v${version}-darwin-x64.zip";
      hash = "sha256-qjYfN835bKxc4kPFvNBW30AnhkuGzV4Wm+PeWJlpGe8=";
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
