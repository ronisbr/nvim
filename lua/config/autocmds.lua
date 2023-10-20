-- Autocmds are automatically loaded on the VeryLazy event.
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Terminal --------------------------------------------------------------------------------

-- Remove line numbers in terminal.
vim.api.nvim_create_autocmd(
  { "TermOpen" }, {
    command = "setlocal nonumber norelativenumber",
  }
)
