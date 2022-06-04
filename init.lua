require('plugins')
require('general')

-- Appearance
-- ============================================================================

require('appearence')

-- Local plugins
-- =============================================================================

require('weather').init()

-- Configuration of the plugins
-- ============================================================================

require('config/alpha-nvim')
require('config/floatterm')
require('config/gitsigns')
require('config/indent-blankline')
require('config/julia')
require('config/hop')
require('config/lspsaga')
require('config/lualine')
require('config/luasnip')
require('config/nvim-cmp')
require('config/nvim-comment')
require('config/nvim-lspconfig')
require('config/nvim-scrollview')
require('config/nvim-tree')
require('config/telescope')
require('config/todo-comments')
require('config/ultisnips')
require('config/undotree')
require('config/vim-better-whitespace')
require('config/vimtex')
require('config/which-key')

-- Key mappings
-- ============================================================================

require('keymappings')

