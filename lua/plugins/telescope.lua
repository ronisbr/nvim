-- Plugin configuration: telescope.nvim ----------------------------------------------------

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        -- Add transparency if we are in neovide.
        winblend = vim.g.neovide and 70 or 0,

        mappings = {
          i = {
            -- Close Telescope when `ESC` is pressed instead of going to normal mode.
            ["<esc>"] = require("telescope.actions").close,
          }
        }
      }
    }
  }
}
