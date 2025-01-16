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
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/projects/obsidian",
        },
      },

      -- see below for full list of options 👇
    },
  },

  {'ojroques/nvim-osc52'},

--   {
--     "kelly-lin/ranger.nvim",
--     config = function()
--       require("ranger-nvim").setup({ replace_netrw = true })
--       vim.api.nvim_set_keymap("n", "<leader>ef", "", {
--         noremap = true,
--         callback = function()
--           require("ranger-nvim").open(true)
--         end,
--       })
--     end,
--   },


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

  -- xbase, it's a big one
  {
      'xbase-lab/xbase',
      build = 'make install',  -- Changed 'run' to 'build' for lazy.nvim
      dependencies = {         -- Changed 'requires' to 'dependencies' for lazy.nvim
          "neovim/nvim-lspconfig",
          "nvim-telescope/telescope.nvim", -- optional
          "nvim-lua/plenary.nvim", -- optional/requirement of telescope.nvim
          -- "stevearc/dressing.nvim", -- optional (in case you don't use telescope but something else)
      },
      config = function()
          require('xbase').setup({
          -- NOTE: Defaults
          -- Log level. Set it to ERROR to ignore everything
          log_level = vim.log.levels.DEBUG,

          -- Options to be passed to lspconfig.nvim's sourcekit setup function.
          -- Setting this to {} is sufficient, However, it is strongly recommended to use on_attach key to setup custom mappings
          sourcekit = {
            cmd = { "sourcekit-lsp", "--log-level", "error" },
            filetypes = { "swift" },
            root_dir = require('lspconfig').util.root_pattern("Package.swift", ".git", "project.yml", "Project.swift", ".xcodeproj"),
          },

          -- Statusline provider configurations
          statusline = {
            watching = { icon = "", color = "#1abc9c" },
            device_running = { icon = "", color = "#4a6edb" },
            success = { icon = "", color = "#1abc9c" },
            failure = { icon = "", color = "#db4b4b" },
          },

          -- Simulators to only include.
          -- run `xcrun simctl list` to get a full list of available simulator
          -- If the list is empty then all simulator available will be included
          simctl = {
            iOS = {
              -- "iPhone 13 Pro", --- only use this devices
            },
            watchOS = {}, -- all available devices
            tvOS = {}, -- all available devices
          },

          -- Log buffer configurations
          log_buffer = {
            -- Whether toggling the buffer should auto focus to it?
            focus = true,
            -- Split Log buffer height
            height = 20,
            -- Vsplit Log buffer width
            width = 75,
            -- Default log buffer direction: { "horizontal", "vertical" }
            default_direction = "horizontal",
          },

          -- Mappings
          mappings = {
            -- Whether xbase mapping should be disabled.
            enable = true,
            -- Open build picker. showing targets and configuration.
            build_picker = "<leader>b", -- set to 0 to disable
            -- Open run picker. showing targets, devices and configuration
            run_picker = "<leader>r", -- set to 0 to disable
            -- Open watch picker. showing run or build, targets, devices and configuration
            watch_picker = "<leader>s", -- set to 0 to disable
            -- A list of all the previous pickers
            all_picker = "<leader>ef", -- set to 0 to disable
            -- horizontal toggle log buffer
            toggle_split_log_buffer = "<leader>ls",
            -- vertical toggle log buffer
            toggle_vsplit_log_buffer = "<leader>lv",
          },

          })

          -- diff function
          require("xbase.statusline").feline()
      end,
  },

  -- Comment plugin
  {
    'numToStr/Comment.nvim',
    config = "require('Comment').setup()"
  },
}, {})





