-- Plugin configuration: nvim-window-picker ------------------------------------------------

return {
  "s1n7ax/nvim-window-picker",
  lazy = true,
  config = function()
    local c = require("nano-theme.colors").get()

    require("window-picker").setup({
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        bo = {
          filetype = { "neo-tree", "neo-tree-popup", "notify" },
          buftype = { "terminal", "quickfix" },
        },
      },

      highlights = {
        statusline = {
          focused   = { fg = c.nano_background_color, bg = c.nano_popout_color },
          unfocused = { fg = c.nano_background_color, bg = c.nano_salient_color }
        },
      },

      selection_chars = "123456789",

      show_prompt = false,
    })
  end
}
