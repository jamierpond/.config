require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "vimdoc", "javascript", "cpp", "typescript", "c", "lua", "rust", "yaml" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Disable treesitter for markdown: nightly 0.12 has a bug in
    -- languagetree.lua injection handling that crashes on :range() nil.
    -- Remove this once the nightly fixes it.
    disable = { "markdown", "markdown_inline" },

    additional_vim_regex_highlighting = false,
  },
}

-- Also override the 0.12 default that enables treesitter highlighting for markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.treesitter.stop(args.buf)
  end,
})

