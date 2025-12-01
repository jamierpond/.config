-- Start yapi watch on save of .yapi.yml files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.yapi.yml", "*.yapi.yaml" },
  callback = function()
    require("yapi_nvim").watch()
  end,
  desc = "Start yapi watch on save",
})
