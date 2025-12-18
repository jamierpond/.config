local M = {}

local preview_buf = nil
local preview_win = nil

local function open_preview_window()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_set_current_win(preview_win)
    return preview_win
  end

  vim.cmd("rightbelow vsplit")
  preview_win = vim.api.nvim_get_current_win()

  vim.wo[preview_win].number = false
  vim.wo[preview_win].relativenumber = false
  vim.wo[preview_win].signcolumn = "no"
  vim.wo[preview_win].foldcolumn = "0"

  return preview_win
end

local function close_preview()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
  end
  preview_win = nil
  preview_buf = nil
end

local function render_markdown(filepath)
  if filepath == "" then
    vim.notify("[mdwatch] Buffer has no file name", vim.log.levels.ERROR)
    return
  end

  if not filepath:match("%.md$") and not filepath:match("%.markdown$") then
    vim.notify("[mdwatch] Not a markdown file", vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    vim.cmd("write")
  end

  local original_win = vim.api.nvim_get_current_win()

  close_preview()

  local win = open_preview_window()
  preview_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, preview_buf)

  vim.fn.termopen({ "mcat", filepath }, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.schedule(function()
          vim.notify("[mdwatch] mcat failed", vim.log.levels.ERROR)
        end)
      end
    end,
  })

  vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { buffer = preview_buf, desc = "Go back to markdown buffer" })

  vim.cmd("startinsert")
end

function M.watch()
  render_markdown(vim.api.nvim_buf_get_name(0))
end

function M.close()
  close_preview()
end

function M.toggle()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    close_preview()
  else
    render_markdown(vim.api.nvim_buf_get_name(0))
  end
end

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command("MdWatch", function()
    M.watch()
  end, { desc = "Render markdown with mcat in split" })

  vim.api.nvim_create_user_command("MdWatchClose", function()
    M.close()
  end, { desc = "Close markdown preview" })

  vim.api.nvim_create_user_command("MdWatchToggle", function()
    M.toggle()
  end, { desc = "Toggle markdown preview" })

  if opts.watch_on_save then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.md", "*.markdown" },
      callback = function()
        if preview_win and vim.api.nvim_win_is_valid(preview_win) then
          M.watch()
        end
      end,
      desc = "Re-render markdown on save",
    })
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      close_preview()
    end,
  })
end

return M
