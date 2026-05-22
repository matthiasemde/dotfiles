{
  pkgs,
  lib,
  ...
}:
{
  programs.neovim = {
    enable = true;

    # Configure nvim as default
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Disable / enable if plugins require either Node, Ruby, or Python
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim

      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
    ];

    extraPackages = with pkgs; [
      ripgrep
      fd
      lua-language-server
      nil
    ];

    initLua = ''
      ------------------------------------------------------------------------------
      -- INSERT-FIRST PHILOSOPHY
      ------------------------------------------------------------------------------

      vim.g.mapleader = " "

      -- Basic UI (minimal)
      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.opt.mouse = "a"
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.clipboard = "unnamedplus"

      ------------------------------------------------------------------------------
      -- MAKE INSERT MODE PRIMARY
      ------------------------------------------------------------------------------

      -- easy escape (important)
      vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })

      -- optional: allow cursor movement without leaving insert mode
      vim.keymap.set("i", "<C-h>", "<Left>")
      vim.keymap.set("i", "<C-l>", "<Right>")
      vim.keymap.set("i", "<C-j>", "<Down>")
      vim.keymap.set("i", "<C-k>", "<Up>")

      ------------------------------------------------------------------------------
      -- VSCode-LIKE KEYBINDS
      ------------------------------------------------------------------------------

      local telescope_builtin = require('telescope.builtin')

      -- Ctrl+P → fuzzy file search
      vim.keymap.set("n", "<C-p>", telescope_builtin.find_files)
      vim.keymap.set("i", "<C-p>", function()
        vim.cmd.stopinsert()
        telescope_builtin.find_files()
      end)

      -- Ctrl+Shift+P → command palette (like VSCode)
      -- same as ":"
      vim.keymap.set("n", "<C-S-p>", ":")
      vim.keymap.set("i", "<C-S-p>", "<Esc>:")

      ------------------------------------------------------------------------------
      -- TELESCOPE
      ------------------------------------------------------------------------------

      require('telescope').setup({})

      ------------------------------------------------------------------------------
      -- LSP (minimal)
      ------------------------------------------------------------------------------

      local lspconfig = vim.lsp.config

      local on_attach = function(_, bufnr)
        local map = function(keys, fn)
          vim.keymap.set('n', keys, fn, { buffer = bufnr })
        end

        map('gd', vim.lsp.buf.definition)
        map('gr', vim.lsp.buf.references)
        map('K', vim.lsp.buf.hover)
        map('<leader>rn', vim.lsp.buf.rename)
      end

      -- lspconfig.lua_ls.setup { on_attach = on_attach }
      -- lspconfig.nil_ls.setup { on_attach = on_attach }

      ------------------------------------------------------------------------------
      -- AUTOCOMPLETE (very minimal)
      ------------------------------------------------------------------------------

      local cmp = require('cmp')

      cmp.setup({
        mapping = cmp.mapping.preset.insert(),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
        }
      })
    '';

  };
}
