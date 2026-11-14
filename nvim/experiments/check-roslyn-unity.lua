local attachTimeoutMilliseconds = 120000
local requestTimeoutMilliseconds = 60000
local pollIntervalMilliseconds = 500

local bufferNumber = vim.api.nvim_get_current_buf()
local function getRoslynClient()
  return vim.lsp.get_clients({ bufnr = bufferNumber, name = "roslyn" })[1]
end
local attached = vim.wait(attachTimeoutMilliseconds, function() return getRoslynClient() ~= nil end, pollIntervalMilliseconds)
print("attached: " .. tostring(attached))
if not attached then vim.cmd("cquit 1") end

local line = vim.fn.search("MonoBehaviour")
local column = vim.fn.getline(line):find("MonoBehaviour") - 1
local params = { textDocument = vim.lsp.util.make_text_document_params(bufferNumber), position = { line = line - 1, character = column } }

local function requestUntilResult(method)
  local result
  vim.wait(requestTimeoutMilliseconds, function()
    local responses = vim.lsp.buf_request_sync(bufferNumber, method, params, requestTimeoutMilliseconds)
    for _, response in pairs(responses or {}) do
      if response.result and not vim.tbl_isempty(response.result) then result = response.result end
    end
    return result ~= nil
  end, pollIntervalMilliseconds)
  return result
end

print("hover: " .. vim.inspect(requestUntilResult("textDocument/hover")):sub(1, 300))
print("definition: " .. vim.inspect(requestUntilResult("textDocument/definition")):sub(1, 300))
print("diagnostics: " .. #vim.diagnostic.get(bufferNumber))
vim.cmd("qa!")
