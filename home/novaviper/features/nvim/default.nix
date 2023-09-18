{ config, lib, pkgs, ... }:
let color = pkgs.writeText "color.vim" (import ./theme.nix config.colorscheme);
in {
  #imports = [];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = # vim
      ''
        set number
        set autoindent
        set smarttab
        set clipboard=unnamedplus

        if (has("termguicolors"))
          set termguicolors
        endif

        "Source colorscheme
        source ${color}
        "colorscheme dracula
      '';
    plugins = with pkgs.vimPlugins; [
      dracula-nvim
      vim-tmux-clipboard
      clipboard-image-nvim
    ];
  };

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
