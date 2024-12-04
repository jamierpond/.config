local builtin = require('telescope.builtin')

-- vim.keymap.set('n', '<leader>pf', "<cmd>Telescope frecency workspace=CWD<CR>", { desc = "Search" })
vim.keymap.set('n', '<leader>pf', builtin.find_files, {}) -- this is the og one

vim.keymap.set('n', '<C-g>', builtin.git_files, {})
-- vim.keymap.set('n', '<leader>ps', function()
--   builtin.grep_string({ search = vim.fn.input("Grep > ") })
-- end)
vim.keymap.set('n', '<leader>ps', "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = "Live Grep"})
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

