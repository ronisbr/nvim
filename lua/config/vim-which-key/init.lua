-- Plugin configuration: vim-which-key
-- ============================================================================

vim.g.which_key_timeout = 100
vim.g.which_key_display_names = {['<CR>'] = '↵', ['<TAB>'] = '⇆'}
vim.g.which_key_sep = '→'
vim.g.which_key_use_floating_win = 0
vim.g.which_key_max_size = 0

-- Hide status line when opening `vim-which-key`, and restore it when existing
-- the buffer.
vim.cmd([[
autocmd! FileType which_key
autocmd FileType which_key highlight default link WhichKeySeperator GitSignsAdd
autocmd FileType which_key set laststatus=0 noshowmode noruler
autocmd FileType which_key autocmd BufLeave <buffer> set laststatus=2 showmode ruler
]])
