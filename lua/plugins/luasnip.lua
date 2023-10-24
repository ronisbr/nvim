-- Plugin configuration: LuaSnip -----------------------------------------------------------

return {
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    config = function ()
      require("snippets.luasnip.julia").config()
      require("luasnip").config.setup({ store_selection_keys = "<Tab>" })
    end
  }
}
