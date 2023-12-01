vim.api.nvim_command('filetype plugin indent on')

vim.api.nvim_command('syntax enable')

vim.g.vimtex_view_method = 'zathura'

vim.g.vimtex_view_general_viewer = 'okular'
vim.g.vimtex_view_general_options = "--unique file:@pdf#src:@line@tex"

vim.g.vimtex_compiler_method = 'pdflatex'


