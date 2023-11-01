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
  local cmd = "!git add . && git commit -m '" .. escaped_message .. "'"
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

local compe = require 'compe'
local telescope = require'telescope.builtin'

function git_checkout()
  telescope.git_branches({
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local selection = require'telescope.actions.state'.get_selected_entry(prompt_bufnr)
        require'telescope.actions'.close(prompt_bufnr)
        if selection then
          vim.cmd('!git checkout ' .. selection.value)
        end
      end)
      return true
    end,
  })
end

local job = require('plenary.job')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')

function create_gh_pr()
  -- Check for uncommitted changes
  local git_status = job:new({ 'git', 'status', '--porcelain' }):sync()
  if #git_status > 0 then
    pickers.new({}, {
      prompt_title = 'Error',
      finder = finders.new_table({
        results = { "You have uncommitted changes. Exiting." }
      }),
      attach_mappings = function(_, map)
        map('i', '<CR>', actions.close)
        return true
      end
    }):find()
    return
  end

  -- Create PR and capture the output
  local pr_create = job:new({ 'gh', 'pr', 'create', '--fill' }):sync()
  for _, line in ipairs(pr_create) do
    print(line)
  end

  -- Get list of files changed in PR for preview
  local pr_files = job:new({ 'git', 'diff', '--name-only', 'HEAD' }):sync()
  print("Files changed in PR:")
  for _, file in ipairs(pr_files) do
    print(file)
  end
end



local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>gc', [[<Cmd>lua git_commit()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gp', [[<Cmd>lua git_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gcp', [[<Cmd>lua git_commit_and_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>co', [[<Cmd>lua git_checkout()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>pr', [[<Cmd>lua create_gh_pr()<CR>]], keymap_opts)

-- web dev stuff
function open_local_host()
  local cmd = "silent !open http://localhost:3000"
  vim.cmd(cmd)
end

vim.api.nvim_set_keymap('n', '<leader>lk', [[<Cmd>lua open_local_host()<CR>]], keymap_opts)


-- some useful python ones
function run_python_file()
  local cmd = "!python3 " .. vim.fn.expand("%")
  vim.cmd(cmd)
end

function run_python_main()
  local cmd = "!python3 " .. vim.fn.expand("%:p:h") .. "/main.py"
  vim.cmd(cmd)
end


-- leader>py to run main
vim.api.nvim_set_keymap('n', '<leader>py', [[<Cmd>lua run_python_main()<CR>]], keymap_opts)

