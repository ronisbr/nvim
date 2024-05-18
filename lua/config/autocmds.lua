-- Autocmds are automatically loaded on the VeryLazy event.
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Syntax ----------------------------------------------------------------------------------

-- Markdown --

vim.api.nvim_create_autocmd(
  {'BufRead', 'BufNewFile'},
  {
    pattern = { '*.md' },
    callback = function()
      vim.fn.matchadd("Special", "#[^# ]\\+")
      vim.fn.matchadd("Special", "#[^#]\\+#")
    end,
  }
)

-- Terminal --------------------------------------------------------------------------------

-- Remove line numbers in terminal.
vim.api.nvim_create_autocmd(
  { "TermOpen" }, {
    command = "setlocal nonumber norelativenumber",
  }
)
