-- Description -----------------------------------------------------------------------------
--
-- Configuration for GitHub Copilot.
--
-- -----------------------------------------------------------------------------------------

-- copilot.vim -----------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "zbirenbaum/copilot.lua" })

    require("copilot").setup({
      nes = {
        enabled = false
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
