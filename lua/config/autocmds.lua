-- Description -----------------------------------------------------------------------------
--
-- Autocmds registraton.
--
-- -----------------------------------------------------------------------------------------

-- Syntax ----------------------------------------------------------------------------------

-- Markdown --

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    pattern = { '*.md' },
    callback = function()
      vim.fn.matchadd("Special", "#[^# ]\\+")
      vim.fn.matchadd("Special", "#[^#]\\+#")
    end,
  }
)

-- vim:ts=2:sts=2:sw=2:et
