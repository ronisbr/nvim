-- Plugin configuration: multicursor.nvim --------------------------------------------------

return {
  "smoka7/multicursors.nvim",
  event = "VeryLazy",
  dependencies = {
    "smoka7/hydra.nvim",
  },
  opts = {},
  cmd = {
    "MCstart",
    "MCvisual",
    "MCclear",
    "MCpattern",
    "MCvisualPattern",
    "MCunderCursor"
  },
  keys = {
    {
      mode = { "v", "n" },
      "<Leader>m",
      "<cmd>MCstart<cr>",
      desc = "Multiple Cursors",
    },
  },
}
