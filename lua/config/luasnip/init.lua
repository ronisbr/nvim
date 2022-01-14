-- Plugin configuration: LuaSnip
-- ============================================================================

local ls = require("luasnip")

-- LuaSnip general configuration
-- =============================================================================

ls.config.setup({store_selection_keys="<Tab>"})

-- Snippets
-- =============================================================================

require("config.luasnip.julia").config()

require("luasnip.loaders.from_vscode").load()
