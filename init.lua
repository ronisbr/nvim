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

require('config/dashboard-nvim')
require('config/floatterm')
require('config/galaxyline')
require('config/gitsigns')
require('config/indent-blankline')
require('config/julia')
require('config/nvim-comment')
require('config/nvim-compe')
require('config/nvim-scrollview')
require('config/nvim-tree')
require('config/telescope')
require('config/todo-comments')
require('config/ultisnips')
require('config/undotree')
require('config/vim-better-whitespace')
require('config/vim-which-key')
require('config/vimtex')

-- Key mappings
-- ============================================================================

require('keymappings')

