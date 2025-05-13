-- Minimal init.lua file to test if neovim starts without errors
vim.cmd([[
  set runtimepath+=~/.config/nvim
  runtime! lua/jamie/init.lua
]])

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

print("Minimal config loaded - if you see this, Neovim started successfully")