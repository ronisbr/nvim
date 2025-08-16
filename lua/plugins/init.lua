-- Description -----------------------------------------------------------------------------
--
-- Configuration for plugins.
--
-- -----------------------------------------------------------------------------------------

require("plugins.colorscheme")

-- We must load copilot **before** mini.completion becuase it overrides the default mapping
-- for <Tab> and <S-Tab>.
require("plugins.copilot")

require("plugins.mini")

require("plugins.julia")
require("plugins.lsp")
require("plugins.treesitter")
require("plugins.vimtex")
require("plugins.undotree")

