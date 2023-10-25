-- Plugin description: virt-column.nvim ----------------------------------------------------

return {
  "lukas-reineke/virt-column.nvim",
  opts = {
    exclude = { 
      filetypes = { "dashboard" },
    },
    virtcolumn = "93",
  },
  lazy = false,
}
