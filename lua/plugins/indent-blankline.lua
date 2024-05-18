-- Plugin configuration: indent-blankline --------------------------------------------------

return {
  "lukas-reineke/indent-blankline.nvim",
  event = "LazyFile",
  opts = {
    exclude = {
      filetypes = {
        "NeogitPopup",
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "floaterm",
        "neogit",
      },
    },
  },
}
