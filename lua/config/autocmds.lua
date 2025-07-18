-- Description -----------------------------------------------------------------------------
--
-- Autocmds registraton.
--
-- -----------------------------------------------------------------------------------------

-- Buffer ----------------------------------------------------------------------------------

-- Close some buffers with specific filetypes using `q`.
-- This autocmd was copied from LazyVim.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ronisbr_close_with_q", { clear = true }),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Syntax ----------------------------------------------------------------------------------

-- Markdown --

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = { "*.md" },
    callback = function()
      vim.fn.matchadd("Special", "#[^# ]\\+")
      vim.fn.matchadd("Special", "#[^#]\\+#")
    end,
  }
)

-- vim:ts=2:sts=2:sw=2:et
