vim.g.mapleader = " "
require("jamie.lazy")
require("jamie.remap")
require("jamie.set")

-- No longer need patches for null-ls (replaced with none-ls)

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.cmd [[
  augroup markdown_settings
    autocmd!
    autocmd FileType markdown setlocal textwidth=0 wrapmargin=0 wrap linebreak
    autocmd FileType markdown setlocal columns=90
  augroup END
]]

-- Set indentation for all files in projects with 'zoo' in the path
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*/zoo/*/*",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end
})


