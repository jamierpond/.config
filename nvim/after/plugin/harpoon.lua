local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
ensure_installed = maintained,

vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu);
vim.keymap.set("n", "<leader>a", function()
  mark.add_file()
  ui.toggle_quick_menu()
end)

-- print someting
vim.keymap.set("n", "<C-7>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<C-f>", function() print("test") end)
vim.keymap.set("n", "<C-9>", function() ui.nav_file(3) end)
vim.keymap.set("n", "<C-0>", function() ui.nav_file(4) end)

