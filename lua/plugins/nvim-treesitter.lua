-- Plugin configuration: nvim-treesitter ---------------------------------------------------

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = {
        enable = true,
        disable = { "markdown" }
      }
    }
  }
}
