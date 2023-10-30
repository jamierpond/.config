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

-- more fun
-- fun git stuff
-- local function git_exec(message, additional_cmd)
-- ok a litte more fun

function display_git_info()
  local output = io.popen("git rev-parse --show-toplevel"):read("*a"):gsub("\n", "")
  vim.api.nvim_out_write("Repo: " .. output .. "\n")

  output = io.popen("git symbolic-ref --short HEAD"):read("*a"):gsub("\n", "")
  vim.api.nvim_out_write("Branch: " .. output .. "\n")

  output = io.popen("git log -n 5 --pretty=format:'%h - %s (%cr)' --date=relative | tac"):read("*a")
  vim.api.nvim_out_write("Last 5 commits:\n" .. output .. "\n")

  output = io.popen("git status -s"):read("*a")
  if output ~= "" then
    vim.api.nvim_out_write("Changes:\n" .. output .. "\n")
  else
    vim.api.nvim_out_write("No changes.\n")
  end
end


function git_commit()
  display_git_info()
  local message = vim.fn.input("Commit message: ")
  local escaped_message = message:gsub("'", "'\\''")
  local cmd = "!git commit -a -m '" .. escaped_message .. "'"
  vim.cmd(cmd)
end

function git_push()
  cmd = "!git push"
  vim.cmd(cmd)
end

function git_commit_and_push()
  display_git_info()
  git_commit()
  git_push()
end

local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>gc', [[<Cmd>lua git_commit()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gp', [[<Cmd>lua git_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gcp', [[<Cmd>lua git_commit_and_push()<CR>]], keymap_opts)


-- web dev stuff
function open_local_host()
  local cmd = "silent !open http://localhost:3000"
  vim.cmd(cmd)
end

vim.api.nvim_set_keymap('n', '<leader>lk', [[<Cmd>lua open_local_host()<CR>]], keymap_opts)


