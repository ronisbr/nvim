-- Plugin configuration: LuaSnip -----------------------------------------------------------

return {
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    config = function ()
      require("snippets.luasnip.julia").config()
      require("luasnip").config.setup({
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        update_events = {"TextChanged", "TextChangedI"}
      })
      require("luasnip.loaders.from_lua").load({
        paths = {"~/.config/nvim/snippets/"}
      })
    end
  }
}
