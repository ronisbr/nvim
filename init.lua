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
require('config/gitsigns')
require('config/indent-blankline')
require('config/julia')
require('config/galaxyline')
require('config/nvim-comment')
require('config/nvim-compe')
require('config/nvim-tree')
require('config/telescope')
require('config/ultisnips')
require('config/undotree')
require('config/vim-better-whitespace')
require('config/vim-which-key')

-- Key mappings
-- ============================================================================

require('keymappings')

