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

    require("sidekick").setup({ })

    -- Keymaps -----------------------------------------------------------------------------

    local function nmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc })
    end

    nmap(
      "<leader>oa",
      function()
        require("sidekick.cli").focus({ name = "copilot" })
      end,
      "Open / Focus Sidekick (Copilot)"
    )
  end
)
