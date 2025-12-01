local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

-- vim.keymap.set('n', '<leader>pf', "<cmd>Telescope frecency workspace=CWD<CR>", { desc = "Search" })
vim.keymap.set('n', '<leader>pf', function()
  builtin.find_files({ hidden = true })
end, {})

vim.keymap.set('n', '<C-g>', builtin.git_files, {})
-- Original live grep behavior
vim.keymap.set('n', '<leader>ps', "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = "Live Grep"})

-- Live grep with auto-quickfix behavior
vim.keymap.set('n', '<leader>pg', function()
  require('telescope').extensions.live_grep_args.live_grep_args({
    attach_mappings = function(_, map)
      -- Override default <CR> to send all results to quickfix
      map('i', '<CR>', function(prompt_bufnr)
        actions.send_to_qflist(prompt_bufnr)
        actions.open_qflist(prompt_bufnr)
      end)
      map('n', '<CR>', function(prompt_bufnr)
        actions.send_to_qflist(prompt_bufnr)
        actions.open_qflist(prompt_bufnr)
      end)
      
      -- Keep ability to send selected items with <M-q>
      map('i', '<M-q>', actions.send_selected_to_qflist + actions.open_qflist)
      map('n', '<M-q>', actions.send_selected_to_qflist + actions.open_qflist)
      
      -- Add <C-o> to open single result without quickfix
      map('i', '<C-o>', actions.select_default)
      map('n', '<C-o>', actions.select_default)
      
      return true
    end,
  })
end, { desc = "Live Grep (auto quickfix)"})

vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

