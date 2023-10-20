-- Plugin configuration: neogit ------------------------------------------------------------

return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  config = true,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "sindrets/diffview.nvim",
    "ibhagwan/fzf-lua",
  },

  lazy = true,
}
