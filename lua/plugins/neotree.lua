-- Plugin configuration: neo-tree.nvim -----------------------------------------------------

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "s1n7ax/nvim-window-picker"
  },
  opts = {
    filesystem = {
      hijack_netrw_behavior = "open_current"
    }
  }
}
