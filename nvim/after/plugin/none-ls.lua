local null_ls = require("null-ls")

-- Register any sources you want to use
local sources = {
  -- Formatting
  -- null_ls.builtins.formatting.prettier,
  -- null_ls.builtins.formatting.stylua,
  -- null_ls.builtins.formatting.black,
  
  -- Diagnostics
  -- null_ls.builtins.diagnostics.eslint,
  -- null_ls.builtins.diagnostics.flake8,
  
  -- Code Actions
  -- null_ls.builtins.code_actions.gitsigns,
}

-- Apply none-ls configuration
null_ls.setup({
  debug = false,
  sources = sources,
  -- Uncomment to format on save
  -- on_attach = function(client, bufnr)
  --   if client.supports_method("textDocument/formatting") then
  --     vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       group = augroup,
  --       buffer = bufnr,
  --       callback = function()
  --         vim.lsp.buf.format({ bufnr = bufnr })
  --       end,
  --     })
  --   end
  -- end,
})