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

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "antosha417/nvim-lsp-file-operations", config = true },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()
      local opts = { noremap = true, silent = true }
      local on_attach = function(_, bufnr)
        opts.buffer = bufnr

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      end

      lspconfig["sourcekit"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,
  },

  {"nvim-telescope/telescope-live-grep-args.nvim"},
  {'mfussenegger/nvim-dap'},


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
--   {
--     "jackMort/ChatGPT.nvim",
--     config = "require('chatgpt').setup()",
--     dependencies = {
--       "MunifTanjim/nui.nvim",
--       "nvim-lua/plenary.nvim",
--       "nvim-telescope/telescope.nvim"
--     }
--   },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {'nvim-lua/plenary.nvim'}
  },

  {
  "nvim-telescope/telescope-frecency.nvim",
  config = function()
    require("telescope").setup({
      extensions = {
        frecency = {
          auto_validate = false,
          matcher = "fuzzy",
          path_display = { "filename_first" }
        }
      }
    })
  end
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





