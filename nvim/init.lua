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


-- set grepprg=rg\ --vimgrep
vim.opt.grepprg = "rg --vimgrep"
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "copen",
})

-- conceallevel 1
-- vim.opt.conceallevel = 1

require("jamie")

