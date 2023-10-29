vim.g.mapleader = " "
vim.key.set("n", "<leader>e", vim.cmd.Ex)

vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true })
vim.api.nvim_set_keymap('i', '<F2>', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })


vim.key.set("v", "J", ":m '>+1<CR>gv=gv")
vim.key.set("v", "K", ":m '<-2<CR>gv=gv")

vim.key.set("n", "J", "mzJ`z")
vim.key.set("n", "<C-d>", "<C-d>zz")
vim.key.set("n", "<C-u>", "<C-u>zz")
vim.key.set("n", "n", "nzzzv")
vim.key.set("n", "N", "Nzzzv")

vim.key.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.key.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.key.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.key.set({"n", "v"}, "<leader>y", [["+y]])
vim.key.set("n", "<leader>Y", [["+Y]])

vim.key.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.key.set("i", "<C-c>", "<Esc>")

vim.key.set("n", "Q", "<nop>")
vim.key.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.key.set("n", "<leader>f", vim.lsp.buf.format)

vim.key.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.key.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.key.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.key.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.key.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.key.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.key.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
vim.key.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.key.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- copy to and from the system clipboard
-- vmap <leader>y !xsel -i -b && xsel -b <CR>
-- nmap <leader>p :r !xsel -b <CR>a
vim.key.set("v", "<leader>y", [["*y]])


