-- Description -----------------------------------------------------------------------------
--
-- Configuration for GitHub Copilot.
--
-- -----------------------------------------------------------------------------------------

-- copilot.vim -----------------------------------------------------------------------------

MiniMisc.on_event(
  "InsertEnter",
  function()
    require("copilot").setup({
      nes = {
        enabled = false
      },
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "<C-p>",
          jump_next = "<C-n>",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>"
        },
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept      = false,
          accept_word = "<C-k>",
          accept_line = "<C-l>",
          next        = "<C-.>",
          previous    = "<C-,>",
          dismiss     = "<C-/>"
        }
      }
    })
  end
)
