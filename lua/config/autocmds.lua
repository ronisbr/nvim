-- Description -----------------------------------------------------------------------------
--
-- Autocmds registraton.
--
-- -----------------------------------------------------------------------------------------

local autocmd_groups = vim.api.nvim_create_augroup("ronisbr_autocmds", { clear = true })

-- Buffer ----------------------------------------------------------------------------------

-- Close some buffers with specific filetypes using `q`.
-- This autocmd was copied from LazyVim.
vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = autocmd_groups,
    pattern = {
      "PlenaryTestPopup",
      "checkhealth",
      "help",
      "lspinfo",
      "minideps-confirm",
      "neotest-output",
      "neotest-summary",
      "notify",
      "qf",
      "spectre_panel",
      "startuptime",
      "tsplayground",
      "neotest-output-panel",
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
    group = autocmd_groups,
    desc = "Auto-close terminal buffer on successful exit",
    callback = function(args)
      if ((vim.v.event.status == 0) and vim.api.nvim_buf_is_valid(args.buf)) then
        vim.cmd({ cmd = "bdelete", args = { args.buf }, bang = true })
      end
    end,
  }
)

-- Reload files changed outside of Neovim.
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
  {
    group = autocmd_groups,
    desc = "Check if file changed on disk",
    callback = function()
      if vim.fn.mode() ~= "c" then
        vim.cmd("checktime")
      end
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

