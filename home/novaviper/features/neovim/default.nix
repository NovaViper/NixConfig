{ config, lib, pkgs, inputs, ... }:
let
  pack = if (config.variables.desktop.displayManager == "wayland") then
    pkgs.wl-clipboard
  else
    pkgs.xclip;
in {
  #home.packages = with pkgs; [ tree-sitter gcc ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [ gcc ];
    opts = {
      # Enabline line numbers
      number = true;
      # Indent a new line the same amount as the line just typed
      autoindent = true;
      # Make case insensitive
      ignorecase = true;
      # Highlight matches when searching
      hlsearch = true;
      # Enable spell check
      spell = true;
      # Use system clipboard
      clipboard = "unnamedplus";
      # Jump to matching bracket if one is inserted
      showmatch = true;
      # Highlight current cursorline
      cursorline = true;
      # Enable mouse support for all modes
      mouse = "a";
      # Enable better terminal colors
      termguicolors = true;
    };
    extraConfigLua = ''
      -- Allow auto-indenting depedning on file type
      -- vim.api.nvim_command('filetype plugin indent on')
    '';
    keymaps = [
      # Use ,, for escape
      # http://vim.wikia.com/wiki/Avoid_the_escape_key
      {
        action = "<Esc>";
        key = ",,";
        mode = [ "i" ];
      }
      # Toggle tagbar
      {
        action = ":TagbarToggle<CR>";
        key = "<leader>tb";
        mode = "n";
        options.silent = true;
      }
      # Toggle line numbers
      {
        action = ":set number! number?<CR>";
        key = "<leader>n";
        mode = "n";
        options.silent = true;
      }
      #" Toggle line wrap
      {
        action = ":set wrap! wrap?<CR>";
        key = "<leader>w";
        mode = "n";
        options.silent = true;
      }
    ];
    plugins = {
      cmp.enable = true;
      cmp-tmux.enable = true;
      cmp-treesitter.enable = true;
      lualine = {
        enable = true;
        extensions = [ "fzf" ];
      };
      startup = {
        enable = true;
        theme = "dashboard";
      };
      clipboard-image = {
        enable = true;
        clipboardPackage = pack;
      };
      neogit.enable = true;
      telescope = {
        enable = true;
        extensions = {
          file_browser.enable = true;
          fzf-native.enable = true;
          media_files.enable = true;
          undo.enable = true;
        };
      };
      treesitter = {
        enable = true;
        nixvimInjections = true;
      };
      which-key.enable = true;
      #tmux-navigator.enable = lib.mkIf (config.programs.tmux.enable) true;
    };
  };
}
