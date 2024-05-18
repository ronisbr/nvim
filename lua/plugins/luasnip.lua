-- Plugin configuration: LuaSnip -----------------------------------------------------------

return {
  "L3MON4D3/LuaSnip",
  lazy = false,
  opts = {
    enable_autosnippets = true,
    store_selection_keys = "<Tab>",
  },
  config = function(_, opts)
    require("luasnip").setup(opts)
    require("snippets.luasnip.julia").config()
    require("luasnip.loaders.from_lua").load({
      paths = {"~/.config/nvim/snippets/"}
    })
  end
}
