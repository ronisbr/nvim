-- Plugin configuration: LuaSnip
-- ============================================================================

local ls = require("luasnip")

-- Function to return the folder of `package.json` from the `friendly-snippets`
-- package. This function is necessary to load the VSCode snippets from a user
-- path together with the package `friendly-snippets`.
local function get_snippet_rtp()
	return vim.tbl_map(function(itm)
		return vim.fn.fnamemodify(itm, ":h")
	end, vim.api.nvim_get_runtime_file("package.json", true))
end

-- LuaSnip general configuration
-- =============================================================================

ls.config.setup({store_selection_keys="<Tab>"})

-- Snippets
-- =============================================================================

require("config.luasnip.julia").config()

require("luasnip.loaders.from_vscode").load({
  paths = {
    unpack(get_snippet_rtp()),
    "~/.nvim/vscode_snippets"
  }
})
