-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin noice.nvim.
--
-- -----------------------------------------------------------------------------------------

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      hover = { enabled = false },
      signature = { enabled = false }
    },

    presets = {
      bottom_search         = false,
      command_palette       = true,
      long_message_to_split = true,
      inc_rename            = false,
    },

    popupmenu = { enabled = false },

    views = {
      cmdline_popup = {
        position = {
          row = 5,
          col = "50%",
        },
        size = {
          width = "60%"
        }
      }
    }
  },
}

-- vim:ts=2:sts=2:sw=2:et
