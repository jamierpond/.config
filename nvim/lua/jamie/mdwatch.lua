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
  anchor_map = nil
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
  end
  preview_win = nil
  preview_buf = nil
end

-- Strip ANSI escape sequences from a string
local function strip_ansi(s)
  return s:gsub("\27%[[%d;]*[A-Za-z]", ""):gsub("\27%]%d;[^\27]*\27\\", "")
end

-- Extract heading anchors from source markdown: { {line=N, text="heading text"}, ... }
local function source_headings(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local anchors = {}
  for i, line in ipairs(lines) do
    local text = line:match("^#+%s+(.+)")
    if text then
      -- Normalize: trim trailing whitespace/hashes
      text = text:gsub("%s*#+%s*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
      table.insert(anchors, { line = i, text = text:lower() })
    end
  end
  return anchors
end

-- Find heading lines in glow terminal buffer by searching for heading text
local function preview_headings(buf, source_anchors)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local anchors = {}

  for _, src in ipairs(source_anchors) do
    for i, line in ipairs(lines) do
      local clean = strip_ansi(line):gsub("^%s+", ""):gsub("%s+$", ""):lower()
      if clean == src.text or clean:find(src.text, 1, true) then
        table.insert(anchors, { source_line = src.line, preview_line = i })
        break
      end
    end
  end

  return anchors
end

-- Cached anchor map, rebuilt on render
local anchor_map = nil

local function build_anchor_map(source_buf)
  if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
    return {}
  end
  local src = source_headings(source_buf)
  return preview_headings(preview_buf, src)
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

  local target_line

  if anchor_map and #anchor_map >= 2 then
    -- Find the two anchors the cursor sits between and interpolate
    local prev_anchor = { source_line = 1, preview_line = 1 }
    local next_anchor = { source_line = total_source, preview_line = total_preview }

    for i, a in ipairs(anchor_map) do
      if a.source_line <= cursor_line then
        prev_anchor = a
        next_anchor = anchor_map[i + 1] or { source_line = total_source, preview_line = total_preview }
      else
        break
      end
    end

    local src_range = next_anchor.source_line - prev_anchor.source_line
    local pre_range = next_anchor.preview_line - prev_anchor.preview_line

    if src_range > 0 then
      local t = (cursor_line - prev_anchor.source_line) / src_range
      target_line = math.floor(prev_anchor.preview_line + t * pre_range + 0.5)
    else
      target_line = prev_anchor.preview_line
    end
  else
    -- Fallback to proportional if not enough anchors
    local ratio = (cursor_line - 1) / (total_source - 1)
    target_line = math.floor(ratio * (total_preview - 1)) + 1
  end

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
      vim.schedule(function()
        if exit_code ~= 0 then
          vim.notify("[mdwatch] glow failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
          return
        end
        -- Build anchor map once glow output is in the buffer
        anchor_map = build_anchor_map(source_buf)
      end)
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
