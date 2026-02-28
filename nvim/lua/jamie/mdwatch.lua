local M = {}

local preview_buf = nil
local preview_win = nil
local scroll_augroup = nil

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
  vim.wo[preview_win].wrap = true

  return preview_win
end

local function clear_scroll_sync()
  if scroll_augroup then
    vim.api.nvim_del_augroup_by_id(scroll_augroup)
    scroll_augroup = nil
  end
end

local function close_preview()
  clear_scroll_sync()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
  end
  preview_win = nil
  preview_buf = nil
end

local function sync_scroll(source_buf)
  if not preview_win or not vim.api.nvim_win_is_valid(preview_win) then
    return
  end
  if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local total_source = vim.api.nvim_buf_line_count(source_buf)
  local total_preview = vim.api.nvim_buf_line_count(preview_buf)

  if total_source <= 1 or total_preview <= 1 then
    return
  end

  local ratio = (cursor_line - 1) / (total_source - 1)
  local target_line = math.floor(ratio * (total_preview - 1)) + 1
  target_line = math.max(1, math.min(target_line, total_preview))

  vim.api.nvim_win_set_cursor(preview_win, { target_line, 0 })
end

local function setup_scroll_sync(source_buf)
  clear_scroll_sync()

  scroll_augroup = vim.api.nvim_create_augroup("MdWatchScrollSync", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = scroll_augroup,
    buffer = source_buf,
    callback = function()
      sync_scroll(source_buf)
    end,
    desc = "Scroll markdown preview proportionally",
  })
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

  local source_buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()

  close_preview()

  local win = open_preview_window()
  local width = vim.api.nvim_win_get_width(win)

  preview_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, preview_buf)

  vim.fn.termopen({ "glow", "-s", "dark", "-w", tostring(width), filepath }, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.schedule(function()
          vim.notify("[mdwatch] glow failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
        end)
      end
    end,
  })

  vim.keymap.set("n", "q", function()
    close_preview()
  end, { buffer = preview_buf, desc = "Close markdown preview" })

  -- Return focus to source window and set up scroll sync
  vim.api.nvim_set_current_win(original_win)
  setup_scroll_sync(source_buf)
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
  end, { desc = "Render markdown with glow in split" })

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
