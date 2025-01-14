{
  tmuxPlugins,
  fetchFromGitHub,
  lib,
  check-jsonschema,
  python3,
  ...
}:
tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-which-key";
  rtpFilePath = "plugin.sh.tmux";
  version = "unstable-2024-06-08";
  propagatedBuildInputs = [check-jsonschema (python3.withPackages (ps: with ps; [pyyaml]))];
  src = fetchFromGitHub {
    owner = "alexwforsythe";
    repo = "tmux-which-key";
    rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
    hash = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
  };
  preInstall = ''
    rm -rf plugin/pyyaml
    ln -s ${python3.pkgs.pyyaml.src} plugin/pyyaml
  '';
}
