local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

lazy.setup({
  {"nvim-lua/plenary.nvim"},
  {"lervag/vimtex"},

  {"mg979/vim-visual-multi"},

  {"hrsh7th/nvim-compe"},

  {"sindrets/diffview.nvim"},

  -- install with yarn or npm
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- ChatGPT plugin
  {
    "jackMort/ChatGPT.nvim",
    config = "require('chatgpt').setup()",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {'nvim-lua/plenary.nvim'}
  },

  -- Rose-pine theme
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = "vim.cmd('colorscheme rose-pine')"
  },

  -- Trouble plugin
  {
    "folke/trouble.nvim",
    config = "require('trouble').setup{icons = false}"
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    config = "require('nvim-treesitter.install').update({ with_sync = true })"
  },
  "nvim-treesitter/playground",
  "theprimeagen/harpoon",
  "theprimeagen/refactoring.nvim",
  "mbbill/undotree",
  "tpope/vim-fugitive",
  "nvim-treesitter/nvim-treesitter-context",

  -- null ls
  {
    'jose-elias-alvarez/null-ls.nvim',
    config = "require('null-ls').config{}",
    requires = {'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig'}
  },


  {
    'williamboman/mason.nvim',
    config = "require('mason').setup({})",
  },

  -- LSP Zero
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    dependencies = {
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  },

  "folke/zen-mode.nvim",
  "github/copilot.vim",
  "eandrju/cellular-automaton.nvim",
  "laytan/cloak.nvim",

  -- Renamer plugin
  {
    'filipdutescu/renamer.nvim',
    branch = 'master',
    dependencies = {'nvim-lua/plenary.nvim'}
  },

  -- Comment plugin
  {
    'numToStr/Comment.nvim',
    config = "require('Comment').setup()"
  },
}, {})





