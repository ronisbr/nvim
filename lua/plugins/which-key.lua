-- Description -----------------------------------------------------------------------------
--
-- Configuration of which-key.nvim and its modules.
--
-- -----------------------------------------------------------------------------------------

return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  opts = {
    preset = "helix"
  },

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      { "<Leader>f", group = "Code" },
      { "<Leader>c", group = "+Code" },
      { "<Leader>f", group = "+Find" },
      { "<Leader>o", group = "+Open" },
      { "<Leader>s", group = "+Snacks" },
      { "<Leader>t", group = "+Text" },

      -- Snacks ----------------------------------------------------------------------------

      { "<Leader>sb", group = "+Buffers" },
      { "<Leader>sg", group = "+Git" },
      { "<Leader>st", group = "+Toggle" },
    })
  end
}

-- vim:ts=2:sts=2:sw=2:et
