-- Description -----------------------------------------------------------------------------
--
-- Configuration of neogit.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    version = false,

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "sindrets/diffview.nvim",
    },

    keys = {
      { "<Leader>og", ":Neogit<CR>", "Open Neogit", silent = true }
    },

    opts = {
      disable_insert_on_commit = false,
      commit_editor = {
        kind = "split",
        staged_diff_split_kind = "vsplit"
      },
      log_view = {
        kind = "vsplit"
      },
      kind = "replace"
    }
  }
}

-- vim:ts=2:sts=2:sw=2:et
