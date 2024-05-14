-- Plugin: markdown.nvim -------------------------------------------------------------------

return {
  "MeanderingProgrammer/markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("render-markdown").setup({
      checkbox = {
        -- Character that will replace the [ ] in unchecked checkboxes.
        unchecked = "󰄱 ",
        -- Character that will replace the [x] in checked checkboxes.
        checked = "󰱒 ",
      },

      highlights = {
        code = "@text.literal.block.markdown",

        checkbox = {
          -- Unchecked checkboxes
          unchecked = "@markup.list.unchecked",
          -- Checked checkboxes
          checked = "@markup.list.checked",
        },

        heading = {
          backgrounds = { "@text.literal.heading.markdown" },
        },

        latex = "@markup.math",

        quote = "@markup.quote",

        table = {
          head = "@markup.heading",
          row = "Normal",
        },
      },
    }) end,
}
