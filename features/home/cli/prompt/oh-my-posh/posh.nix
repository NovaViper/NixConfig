_: {
  features.prompt = "oh-my-posh";

  programs.oh-my-posh.enable = true;

  programs.oh-my-posh.settings = {
    "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
    version = 2;
    final_space = true;
    disable_notice = true;
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
