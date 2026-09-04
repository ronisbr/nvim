-- Description -----------------------------------------------------------------------------
--
-- Autocmds registraton.
--
-- -----------------------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup("ronisbr_autocmds", { clear = true })

-- Buffer ----------------------------------------------------------------------------------

-- Close some buffers with specific filetypes using `q`.
-- This autocmd was copied from LazyVim.
vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = augroup,
    pattern = {
      "PlenaryTestPopup",
      "checkhealth",
      "help",
      "lspinfo",
      "minideps-confirm",
      "neotest-output",
      "neotest-output-panel",
      "neotest-summary",
      "notify",
      "nvim-undotree",
      "qf",
      "spectre_panel",
      "startuptime",
      "tsplayground",
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  }
)

vim.api.nvim_create_autocmd(
  "BufWinEnter",
  {
    pattern = "copilot:/*",
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  }
)

-- Automatically close terminal buffers when the process exits with status 0.
vim.api.nvim_create_autocmd(
  "TermClose",
  {
    group = augroup,
    desc = "Auto-close terminal buffer on successful exit",
    callback = function(args)
      if ((vim.v.event.status == 0) and vim.api.nvim_buf_is_valid(args.buf)) then
        vim.cmd({ cmd = "bdelete", args = { args.buf }, bang = true })
      end
    end,
  }
)

-- Highlight the text affected by yank and put operations.
vim.api.nvim_create_autocmd(
  { "TextYankPost", "TextPutPost" },
  {
    group = augroup,
    desc = "Highlight yanked and put text",
    callback = function()
      vim.hl.hl_op({ higroup = "Visual", timeout = 200 })
    end,
  }
)

-- Syntax ----------------------------------------------------------------------------------

-- Markdown --

vim.api.nvim_create_autocmd(
  {"BufRead", "BufNewFile"},
  {
    pattern = { "*.md" },
    callback = function()
      vim.fn.matchadd("Special", "#[^# ]\\+")
      vim.fn.matchadd("Special", "#[^#]\\+#")
    end,
  }
)

