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
augroup which_key_group
autocmd FileType which_key highlight default link WhichKeySeperator GitSignsAdd
  set laststatus=0 noshowmode noruler
autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler
augroup end
]])
