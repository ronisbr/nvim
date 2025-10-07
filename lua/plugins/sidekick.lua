-- Description -----------------------------------------------------------------------------
--
-- Configuration for sidekick.nvim.
--
-- Dependencies ----------------------------------------------------------------------------
--
-- It is necessary to install GitHub Copilot CLI using:
--
--     npm install -g @github/copilot
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "folke/sidekick.nvim" })

    require("sidekick").setup({
      cli = {
        prompts = {
          improve  = "Can you please improve the code in {file}?",
          optimize = "Can you please optimize the code in {file}?",
          spell    = "Can you please fix the spelling mistakes in {file}?",
        }
      }
    })

    -- Keymaps -----------------------------------------------------------------------------

    local function nmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc })
    end

    nmap(
      "<C-g>",
      function() require("sidekick").nes_jump_or_apply() end,
      "Goto/Apply Next Edit Suggestion"
    )

    nmap(
      "<Leader>oa",
      function() require("sidekick.cli").focus({ name = "copilot" }) end,
      "Open / Focus Sidekick (Copilot)"
    )

    nmap(
      "<Leader>ap",
      function() require("sidekick.cli").prompt() end,
      "Sidekick Prompt Picker"
    )
  end
)
