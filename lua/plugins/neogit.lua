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
    log_view = {
      kind = "replace"
    },
    kind = "replace"
  }
}
