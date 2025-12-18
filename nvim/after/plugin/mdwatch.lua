local mdwatch = require("jamie.mdwatch")

mdwatch.setup({
  watch_on_save = true,
})

vim.keymap.set("n", "<leader>m", function()
  mdwatch.toggle()
end, { desc = "Toggle markdown preview" })
