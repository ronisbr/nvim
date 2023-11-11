-- Plugin configuration: headlines.nvim ----------------------------------------------------

return {
  {
    "lukas-reineke/headlines.nvim",
    lazy = true,
    ft = "markdown",
    opts = {
      markdown = {
        fat_headlines = true,
        fat_headline_upper_string = "",
        fat_headline_lower_string = "‾",
        codeblock_highlight = "@text.literal.block.markdown"
      }
    }
  }
}
