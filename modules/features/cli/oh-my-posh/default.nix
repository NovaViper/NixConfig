{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  internals = import ./utils.nix {};
in
  {imports = [./snippet.nix];}
  // myLib.utilMods.mkModule config "oh-my-posh" {
    hm.programs.oh-my-posh.enable = true;

    hm.programs.oh-my-posh.settings = {
      "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
      version = 2;
      final_space = true;
      disable_notice = true;
      var.PromptChar = "${internals.ucode "276F"}";
      # llakala coming in a clutch once again!
      blocks = import ./blocks.nix {inherit lib internals;};
      transient_prompt = {
        background = "transparent";
        foreground_templates = [
          "{{if gt .Code 0}}1{{end}}"
          "{{if eq .Code 0}}10{{end}}"
        ];
        template = "{{.Var.PromptChar}} ";
      };
    };
  }
