{ pkgs, inputs, ... }:
let
  finecmdline = pkgs.vimUtils.buildVimPlugin {
    name = "fine-cmdline";
    src = inputs.fine-cmdline;
  };
in
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [
        xclip
        wl-clipboard
        nil
        lua-language-server
        haskell-language-server
        clang-tools
        ripgrep
      ];
      plugins = with pkgs.vimPlugins; [
        alpha-nvim
        bufferline-nvim
        # dressing-nvim
        indent-blankline-nvim
        nui-nvim
        finecmdline
        nvim-treesitter.withAllGrammars
        lualine-nvim
        nvim-autopairs
        nvim-web-devicons
        nvim-cmp
        nvim-surround
        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        luasnip
        cmp_luasnip
        friendly-snippets
        lspkind-nvim
        comment-nvim
        nvim-ts-context-commentstring
        oil-nvim
        plenary-nvim
        neodev-nvim
        luasnip
        telescope-nvim
        todo-comments-nvim
        nvim-tree-lua
        telescope-fzf-native-nvim
        vim-tmux-navigator
        nvim-notify
        mason-nvim
        mason-lspconfig-nvim
        catppuccin-nvim
        vim-fugitive
      ];
      extraConfig = '''';
      extraLuaConfig = ''
        ${builtins.readFile ./lua/set.lua}
        ${builtins.readFile ./lua/remap.lua}
        ${builtins.readFile ./lua/plugins/alpha.lua}
        ${builtins.readFile ./lua/plugins/autopairs.lua}
        ${builtins.readFile ./lua/plugins/bufferline.lua}
        ${builtins.readFile ./lua/plugins/cmp.lua}
        ${builtins.readFile ./lua/plugins/comment.lua}
        ${builtins.readFile ./lua/plugins/gruvbox-nvim.lua}
        ${builtins.readFile ./lua/plugins/fine-cmdline.lua}
        ${builtins.readFile ./lua/plugins/lualine.lua}
        ${builtins.readFile ./lua/plugins/lsp.lua}
        ${builtins.readFile ./lua/plugins/notify.lua}
        ${builtins.readFile ./lua/plugins/oil.lua}
        ${builtins.readFile ./lua/plugins/telescope.lua}
        ${builtins.readFile ./lua/plugins/treesitter.lua}
        require("ibl").setup()
      '';
    };
  };
}
