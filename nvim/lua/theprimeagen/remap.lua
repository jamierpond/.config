vim.g.mapleader = " "

vim.api.nvim_set_keymap("n", "<leader>e", ":Ex<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true })
vim.api.nvim_set_keymap('i', '<F2>', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })

vim.api.nvim_set_keymap("v", "J", ":m '>+1<CR>gv=gv", {})
vim.api.nvim_set_keymap("v", "K", ":m '<-2<CR>gv=gv", {})
vim.api.nvim_set_keymap("n", "J", "mzJ`z", {})
vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", {})
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", {})
vim.api.nvim_set_keymap("n", "n", "nzzzv", {})
vim.api.nvim_set_keymap("n", "N", "Nzzzv", {})

vim.api.nvim_set_keymap("n", "<leader>vwm", "<cmd>lua require('vim-with-me').StartVimWithMe()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>svwm", "<cmd>lua require('vim-with-me').StopVimWithMe()<CR>", { noremap = true })

vim.api.nvim_set_keymap("x", "<leader>p", [["_dP"]], {})
vim.api.nvim_set_keymap("n", "<leader>y", [["+y]], {})
vim.api.nvim_set_keymap("n", "<leader>Y", [["+Y]], {})
vim.api.nvim_set_keymap("n", "<leader>d", [["_d"]], {})
vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", {})
vim.api.nvim_set_keymap("n", "Q", "<nop>", {})
vim.api.nvim_set_keymap("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>f", ":lua vim.lsp.buf.format()<CR>", {})

vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>cnext<CR>zz", {})
vim.api.nvim_set_keymap("n", "<C-j>", "<cmd>cprev<CR>zz", {})
vim.api.nvim_set_keymap("n", "<leader>k", "<cmd>lnext<CR>zz", {})
vim.api.nvim_set_keymap("n", "<leader>j", "<cmd>lprev<CR>zz", {})

vim.api.nvim_set_keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {})
vim.api.nvim_set_keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", {})

vim.api.nvim_set_keymap("n", "<leader><leader>", ":so<CR>", {})

vim.api.nvim_set_keymap("v", "<leader>y", [["*y]], {})

vim.cmd([[command! -nargs=+ Gc !git commit -a -m "<args>"]])
vim.cmd([[command! Gp !git push]])
vim.cmd([[command! Kat !killall tmux]])
vim.cmd([[command! Kan !killall node]])

vim.api.nvim_set_keymap('n', '<leader>gc', [[<Cmd>lua git_commit()<CR>]], { noremap = true, silent = true })

function git_commit()
  local message = vim.fn.input("Commit message: ")
  if message ~= "" then
    vim.cmd("!git add . && git commit -m '" .. message .. "'")
  end
end

vim.api.nvim_set_keymap('n', '<leader>gp', [[<Cmd>!git push<CR>]], { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>gcp', [[<Cmd>lua git_commit_and_pull()<CR>]], { noremap = true, silent = true })

function git_commit_and_pull()
  local message = vim.fn.input("Commit message: ")
  if message ~= "" then
    vim.cmd("!git add . && git commit -m '" .. message .. "' && git pull")
  else
    vim.cmd("!git pull")
  end
  -- Show last 5 commits
  vim.cmd("!git log -n 5 --pretty=format:'%h - %s (%cr)'")
end



