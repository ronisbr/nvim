-- Description -----------------------------------------------------------------------------
--
-- Autocmds registraton.
--
-- -----------------------------------------------------------------------------------------

-- Buffer ----------------------------------------------------------------------------------

-- This autocmd was copied from LazyVim.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("ronisbr_last_loc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

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

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    pattern = { '*.md' },
    callback = function()
      vim.fn.matchadd("Special", "#[^# ]\\+")
      vim.fn.matchadd("Special", "#[^#]\\+#")
    end,
  }
)

-- vim:ts=2:sts=2:sw=2:et
