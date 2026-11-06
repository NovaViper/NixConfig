{ lib, ... }:
{
  # Use Zellij's built-in layout and status bar on Terminus.
  hm.programs.zellij = {
    plugins = lib.mkForce [ ];
    layouts = lib.mkForce { };
    settings.load_plugins = lib.mkForce { };
  };
}
