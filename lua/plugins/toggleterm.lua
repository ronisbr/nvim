-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins toogleterm.nvim.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "akinsho/toggleterm.nvim",

    keys = {
      { "<Leader>ot", ":ToggleTerm<CR>", desc = "Open Terminal", silent = true }
    },

    opts = {
      direction = "float",
      float_opts = {
        border = "curved"
      }
    },

    config = function(_, opts)
      require("toggleterm").setup(opts)

      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("ronisbr-term-open", { clear = true }),

        callback = function(event)
          local map = vim.keymap.set

          -- Keymaps -------------------------------------------------------------------------

          map("t", "<Esc>", "<C-\\><C-n>", { silent = true })
        end})
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
