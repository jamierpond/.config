-- Toggle yapi watch with <leader>r
vim.keymap.set("n", "<leader>r", function()
  local ok, yapi = pcall(require, "yapi_nvim")
  if not ok then
    vim.notify("yapi_nvim not installed (~/projects/yapi/integrations/nvim missing)", vim.log.levels.WARN)
    return
  end
  local current_win = vim.api.nvim_get_current_win()
  yapi.toggle()
  -- Restore focus to editing window if we opened (not closed)
  if vim.api.nvim_get_current_win() ~= current_win then
    vim.api.nvim_set_current_win(current_win)
  end
end, { desc = "Toggle yapi watch" })
