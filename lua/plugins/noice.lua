-- Plugin configuration: noice.nvim --------------------------------------------------------

return {
  {
    "folke/noice.nvim",
    opts = {
      views = {
        mini = {
          -- We will not use the status bar. Thus, let's move this view to the very bottom.
          position = { row = "100%", col = "100%" }
        }
      }
    }
  }
}
