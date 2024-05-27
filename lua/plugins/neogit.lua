-- Plugin configuration: neogit ------------------------------------------------------------

return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  config = true,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "sindrets/diffview.nvim",
  },

  lazy = true,

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
