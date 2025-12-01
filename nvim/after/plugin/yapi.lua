-- Run yapi on save for .yapi.yml files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.yapi.yml", "*.yapi.yaml" },
  callback = function()
    require("yapi_nvim").run()
  end,
  desc = "Run yapi on save",
})
