local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
ensure_installed = maintained,

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)

-- vim.keymap.set("n", "7", function() ui.nav_file(1) end)
-- vim.keymap.set("n", "8", function() ui.nav_file(2) end)
-- vim.keymap.set("n", "9", function() ui.nav_file(3) end)
-- vim.keymap.set("n", "0", function() ui.nav_file(4) end)


