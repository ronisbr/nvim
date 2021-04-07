-- Plugin configuration: neogit
-- ============================================================================

-- Disable `colorbar` in neogit buffers.
vim.cmd [[
autocmd FileType Neogit,NeogitStatus,NeogitLog setlocal colorcolumn=0
autocmd BufFilePost * if (bufname() == 'NeogitLogPopup') || (bufname() == 'NeogitHelpPopup') |
    setlocal colorcolumn=0 |
  endif
]]
