{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ tree-sitter gcc ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = # vim
      ''
        set number                      " Add line numbers
        set autoindent                  " Indent a new line the same amount as the line just typed
        set ignorecase                  " Case insensitive
        set hlsearch                    " Highlight matches when searching
        "set spell                       " Enable spell check
        set clipboard=unnamedplus       " Use system clipboard
        set showmatch                   " Show matching
        set cursorline                  " highlight current cursorline
        set mouse=a                     " enable mouse click

        if (has("termguicolors"))
          set termguicolors
        endif

        " Enable Dracula theme
        colorscheme dracula

        " Allow auto-indenting depedning on file type
        filetype plugin indent on

        " Change the leader key from "\" to ";" ("," is also popular)
        let mapleader = ","

        " Use ,, for escape
        " http://vim.wikia.com/wiki/Avoid_the_escape_key
        inoremap ,, <Esc>

        " Toggle tagbar
        " nnoremap <silent> <leader>tb :TagbarToggle<CR>
        " Toggle line numbers
        nnoremap <silent> <leader>n :set number! number?<CR>
        " Toggle line wrap
        nnoremap <silent> <leader>w :set wrap! wrap?<CR>
      '';
    extraLuaConfig = ''
      -- Configure lualine
      require('lualine').setup {
        options = {
          theme = 'dracula-nvim',
        }
      }
      require("startup").setup({theme = "dashboard"}) -- put theme name here
    '';
    plugins = with pkgs.vimPlugins; [
      dracula-nvim
      vim-tmux-clipboard
      clipboard-image-nvim
      lualine-nvim
      neogit
      telescope-nvim
      telescope-file-browser-nvim
      nvim-treesitter.withAllGrammars
      which-key-nvim
      startup-nvim
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
