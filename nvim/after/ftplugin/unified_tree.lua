local function reposition_diff()
  local win = require("unified.state").get_main_window()
  if not win or not vim.api.nvim_win_is_valid(win) then return end
  vim.wo[win].relativenumber = false
  pcall(vim.api.nvim_win_call, win, function() vim.cmd("normal! zt") end)
end

local function wrap(fn)
  return function()
    fn()
    reposition_diff()
  end
end

local actions = function() return require("unified.file_tree.actions") end

vim.keymap.set("n", "<CR>", wrap(function() actions().toggle_node() end),
  { noremap = true, silent = true, buffer = true })
vim.keymap.set("n", "j", wrap(function() actions().move_cursor_and_open_file(1) end),
  { noremap = true, silent = true, buffer = true })
vim.keymap.set("n", "k", wrap(function() actions().move_cursor_and_open_file(-1) end),
  { noremap = true, silent = true, buffer = true })
vim.keymap.set("n", "<Down>", wrap(function() actions().move_cursor_and_open_file(1) end),
  { noremap = true, silent = true, buffer = true })
vim.keymap.set("n", "<Up>", wrap(function() actions().move_cursor_and_open_file(-1) end),
  { noremap = true, silent = true, buffer = true })
