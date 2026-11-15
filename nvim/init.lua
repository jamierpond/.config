-- set grepprg=rg\ --vimgrep
vim.opt.grepprg = "rg --vimgrep"
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "copen",
})

-- conceallevel 1
-- vim.opt.conceallevel = 1

require("jamie")

