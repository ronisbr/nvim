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
        mux = {
          enabled = true,
          backend = "tmux"
        },
        prompts = {
          improve  = "Can you please improve the code in {file}?",
          optimize = "Can you please optimize the code in {file}?",
          spell    = "Can you please fix the spelling and grammar mistakes in {file}?",
        }
      },
    })

    -- Keymaps -----------------------------------------------------------------------------

    local function keymap(lhs, rhs, desc, mode)
      vim.keymap.set(mode, lhs, rhs, { desc = desc })
    end

    keymap(
      "<Tab>",
      function()
        require("sidekick").nes_jump_or_apply()
      end,
      "Goto/Apply Next Edit Suggestion",
      { "n" }
    )

    keymap(
      "<Leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      "Sidekick Prompt Picker",
      "n"
    )

    keymap(
      "<C-.>",
      function()
        require("sidekick.cli").toggle({ filter = { installed = true }})
      end,
      "Sidekick Toggle",
      { "n", "t", "i", "x" }
    )

    keymap(
      "<leader>at",
      function()
        require("sidekick.cli").send({
          filter = { installed = true },
          msg    = "{this}"
        })
      end,
      "Send This",
      { "x", "n" }
    )

    keymap(
      "<leader>af",
      function()
        require("sidekick.cli").send({
          filter = { installed = true },
          msg    = "{file}"
        })
      end,
      "Send File",
      "n"
    )

    keymap(
      "<leader>av",
      function()
        require("sidekick.cli").send({
          filter = { installed = true },
          msg    = "{selection}"
        })
      end,
      "Send Visual Selection",
      "x"
    )

    keymap(
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      "Sidekick Select Prompt",
      { "n", "x" }
    )
  end
)
