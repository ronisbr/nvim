-- Description -----------------------------------------------------------------------------
--
-- Configuration for GitHub Copilot.
--
-- -----------------------------------------------------------------------------------------

-- copilot.vim -----------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "copilotlsp-nvim/copilot-lsp" })
    MiniDeps.add({ source = "zbirenbaum/copilot.lua" })

    require("copilot-lsp").setup({})

    require("copilot").setup({
      nes = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<C-g>",
          dismiss         = "<Esc>"
        }
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
      },
    })
  end
)
