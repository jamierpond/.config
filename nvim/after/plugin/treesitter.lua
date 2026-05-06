-- Monkey-patch get_node_text to handle nil range (nightly 0.12 bug).
-- Remove once nvim-treesitter or nightly fixes the invalidated node issue.
local original_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  local ok, result = pcall(original_get_node_text, node, source, opts)
  if ok then
    return result
  end
  return ""
end

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

    additional_vim_regex_highlighting = false,
  },
}

