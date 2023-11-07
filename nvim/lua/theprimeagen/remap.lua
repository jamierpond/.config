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
vim.cmd([[command! Pull !git pull]])
vim.cmd([[command! Kat !killall tmux]])
vim.cmd([[command! Kan !killall node]])

vim.cmd([[command! Dt !say "dogtown?"]])

-- we want to run the script in ~/.config/bin/scripts/localhost-qr
vim.cmd([[command! -nargs=1 Qr !~/.config/bin/scripts/localhost-qr "<args>"]])
-- now also the same for <leader>qr, but we should pop up a question for the port

function GetLocalHostQr()
  local port = vim.fn.input("Enter port: ")
  if port == "" then
    port = "3000"
  end
  local cmd = "!~/.config/bin/scripts/localhost-qr " .. port
  vim.cmd(cmd)
end

vim.api.nvim_set_keymap("n", "<leader>qr", [[<Cmd>lua GetLocalHostQr()<CR>]], { noremap = true })


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
  local add_all = "!git add ."
  vim.cmd(add_all)
  local message = vim.fn.input("Commit message: ")
  local escaped_message = message:gsub("'", "'\\''")
  local cmd = "!git add . && git commit -m '" .. escaped_message .. "'"
  vim.cmd(cmd)
end

function git_push()
  -- set the upstream just in case
  current_branch = io.popen("git branch --show-current"):read("*a"):gsub("\n", "")
  local cmd = "!git push --set-upstream origin " .. current_branch
  vim.cmd(cmd)
  cmd = "!git push"
  vim.cmd(cmd)
end

function git_commit_and_push()
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

function create_new_branch()
  local new_branch_name = vim.fn.input("Enter new branch name: ")

  local git_status = job:new({ 'git', 'status', '--porcelain' }):sync()
  local stash = 'No'

  if #git_status > 0 then
    stash = vim.fn.input("Stash changes? (Yes/No): ")
  end

  local current_branch = job:new({ 'git', 'branch', '--show-current' }):sync()[1]
  local default_branch = job:new({ 'git', 'symbolic-ref', 'refs/remotes/origin/HEAD' }):sync()[1]:gsub('refs/remotes/origin/', '')

  local base_branch = current_branch

  if current_branch ~= default_branch then
    base_branch = vim.fn.input("Base off which branch? (" .. current_branch .. "/" .. default_branch .. "): ")
  end

  if stash == 'Yes' then
    job:new({ 'git', 'stash' }):sync()
  end

  job:new({ 'git', 'checkout', '-b', new_branch_name, base_branch }):sync()

  if stash == 'Yes' then
    job:new({ 'git', 'stash', 'apply' }):sync()
  end

  print("New branch " .. new_branch_name .. " created off " .. base_branch)

  job:new({ 'git', 'push', '--set-upstream', 'origin', new_branch_name }):sync()
  print("New branch " .. new_branch_name .. " pushed to origin")
end

local job = require('plenary.job')

function create_gh_pr()
    -- Get the current branch name
  local current_branch = job:new({ 'git', 'branch', '--show-current' }):sync()[1]

  -- Check if a PR already exists for the current branch
  -- Print syncronously so we don't try and press the shortcut again!
  job:new({ 'echo', 'Checking for existing PR...' }):sync()

  local existing_pr = job:new({ 'gh', 'pr', 'list', '--search', current_branch }):sync()

  job:new({ 'echo', 'Existing PR: ' .. existing_pr }):sync()

--   if #existing_pr > 0 then
--     print("Existing PR found for this branch. Opening...")
--     job:new({ 'gh', 'pr', 'view', '--web' }):sync()
--     return
--   end
--
--   -- Check for uncommitted changes, more changes
--   local git_status = job:new({ 'git', 'status', '--porcelain' }):sync()
--   if #git_status > 0 then
--     local commit_option = vim.fn.input("You have uncommitted changes. Commit them? (Yes/No): ")
--     if commit_option == 'Yes' then
--       git_commit()
--       git_push()
--     else
--       print("Exiting. Uncommitted changes exist.")
--       return
--     end
--   end
--
--   -- Check for unpushed commits
--   local unpushed_commits = job:new({ 'git', 'log', '@{u}..', '--oneline' }):sync()
--   if #unpushed_commits > 0 then
--     local push_option = vim.fn.input("You have unpushed commits. Push them? (Yes/No): ")
--     if push_option == 'Yes' then
--       git_push()
--     else
--       print("Exiting. Unpushed commits exist.")
--       return
--     end
--   end
--
--   -- Ask for PR name
--   local pr_name = vim.fn.input("Enter the name of the new PR: ")
--
--   -- Create PR
--   job:new({
--     command = 'gh',
--     args = { 'pr', 'create', '--fill', '--title', pr_name },
--     on_exit = function(j, return_val)
--       if return_val == 0 then
--         print("PR successfully created.")
--         -- Open the PR in the browser asynchronously
--         job:new({
--           command = 'gh',
--           args = { 'pr', 'view', '--web' },
--           on_exit = function(j, return_val)
--             if return_val == 0 then
--               print("PR opened in web browser.")
--             else
--               print("Failed to open PR in web browser.")
--             end
--           end,
--         }):start()
--       else
--         print("Failed to create PR.")
--       end
--     end,
--   }):start()
end


local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>gc', [[<Cmd>lua git_commit()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gp', [[<Cmd>lua git_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gcp', [[<Cmd>lua git_commit_and_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>co', [[<Cmd>lua git_checkout()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>pr', [[<Cmd>lua create_gh_pr()<CR>]], keymap_opts)

vim.api.nvim_set_keymap('n', '<leader>b', [[<Cmd>lua create_new_branch()<CR>]], keymap_opts)

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
  local add_all = "!git add ."
  vim.cmd(add_all)
  local message = vim.fn.input("Commit message: ")
  local escaped_message = message:gsub("'", "'\\''")
  local cmd = "!git add . && git commit -m '" .. escaped_message .. "'"
  vim.cmd(cmd)
end

function git_push()
  -- set the upstream just in case
  current_branch = io.popen("git branch --show-current"):read("*a"):gsub("\n", "")
  local cmd = "!git push --set-upstream origin " .. current_branch
  vim.cmd(cmd)
  cmd = "!git push"
  vim.cmd(cmd)
end

function git_commit_and_push()
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

function create_new_branch()
  local new_branch_name = vim.fn.input("Enter new branch name: ")

  local git_status = job:new({ 'git', 'status', '--porcelain' }):sync()
  local stash = 'No'

  if #git_status > 0 then
    stash = vim.fn.input("Stash changes? (Yes/No): ")
  end

  local current_branch = job:new({ 'git', 'branch', '--show-current' }):sync()[1]
  local default_branch = job:new({ 'git', 'symbolic-ref', 'refs/remotes/origin/HEAD' }):sync()[1]:gsub('refs/remotes/origin/', '')

  local base_branch = current_branch

  if current_branch ~= default_branch then
    base_branch = vim.fn.input("Base off which branch? (" .. current_branch .. "/" .. default_branch .. "): ")
  end

  if stash == 'Yes' then
    job:new({ 'git', 'stash' }):sync()
  end

  job:new({ 'git', 'checkout', '-b', new_branch_name, base_branch }):sync()

  if stash == 'Yes' then
    job:new({ 'git', 'stash', 'apply' }):sync()
  end

  print("New branch " .. new_branch_name .. " created off " .. base_branch)

  job:new({ 'git', 'push', '--set-upstream', 'origin', new_branch_name }):sync()
  print("New branch " .. new_branch_name .. " pushed to origin")
end

local job = require('plenary.job')

function create_gh_pr()
    -- Get the current branch name
  local current_branch = job:new({ 'git', 'branch', '--show-current' }):sync()[1]

  -- Check if a PR already exists for the current branch
  -- Print syncronously so we don't try and press the shortcut again!

  job:new({ 'echo', 'Checking for existing PR...' }):sync()

  local existing_pr = job:new({ 'gh', 'pr', 'list', '--search', current_branch }):sync()

  if #existing_pr > 0 then
    print("Existing PR found for this branch. Opening...")
    job:new({ 'gh', 'pr', 'view', '--web' }):sync()
    return
  end

  -- Check for uncommitted changes, more changes
  local git_status = job:new({ 'git', 'status', '--porcelain' }):sync()
  if #git_status > 0 then
    local commit_option = vim.fn.input("You have uncommitted changes. Commit them? (Yes/No): ")
    if commit_option == 'Yes' then
      git_commit()
      git_push()
    else
      print("Exiting. Uncommitted changes exist.")
      return
    end
  end

  -- Check for unpushed commits
  local unpushed_commits = job:new({ 'git', 'log', '@{u}..', '--oneline' }):sync()
  if #unpushed_commits > 0 then
    local push_option = vim.fn.input("You have unpushed commits. Push them? (Yes/No): ")
    if push_option == 'Yes' then
      git_push()
    else
      print("Exiting. Unpushed commits exist.")
      return
    end
  end

  -- Ask for PR name
  local pr_name = vim.fn.input("Enter the name of the new PR: ")

  -- Create PR
  job:new({
    command = 'gh',
    args = { 'pr', 'create', '--fill', '--title', pr_name },
    on_exit = function(j, return_val)
      if return_val == 0 then
        print("PR successfully created.")
        -- Open the PR in the browser asynchronously
        job:new({
          command = 'gh',
          args = { 'pr', 'view', '--web' },
          on_exit = function(j, return_val)
            if return_val == 0 then
              print("PR opened in web browser.")
            else
              print("Failed to open PR in web browser.")
            end
          end,
        }):start()
      else
        print("Failed to create PR.")
      end
    end,
  }):start()
end


local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>gc', [[<Cmd>lua git_commit()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gp', [[<Cmd>lua git_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>gcp', [[<Cmd>lua git_commit_and_push()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>co', [[<Cmd>lua git_checkout()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>pr', [[<Cmd>lua create_gh_pr()<CR>]], keymap_opts)

vim.api.nvim_set_keymap('n', '<leader>b', [[<Cmd>lua create_new_branch()<CR>]], keymap_opts)

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

-- hello this is a change i am going to pr
