-- Toggle yapi watch with <leader>r
vim.keymap.set("n", "<leader>r", function()
  local yapi = require("yapi_nvim")
  local current_win = vim.api.nvim_get_current_win()
  yapi.toggle()
  -- Restore focus to editing window if we opened (not closed)
  if vim.api.nvim_get_current_win() ~= current_win then
    vim.api.nvim_set_current_win(current_win)
  end
end, { desc = "Toggle yapi watch" })
