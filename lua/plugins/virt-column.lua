-- Plugin description: virt-column.nvim ----------------------------------------------------

return {
  "lukas-reineke/virt-column.nvim",
  opts = {
    char = "│",
    exclude = {
      filetypes = { "dashboard", "markdown" },
    },
    virtcolumn = "93",
  },
  lazy = false,
}
