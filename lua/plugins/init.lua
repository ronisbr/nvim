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

require("plugins.aiwaku")
require("plugins.julia")
require("plugins.lsp")
require("plugins.multicursor")
require("plugins.treesitter")
require("plugins.typst")
require("plugins.undotree")
require("plugins.vimtex")

require("plugins.none-ls")

MiniDeps.later(
  function()
    local float_bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg
    local float_fg = vim.api.nvim_get_hl(0, { name = "Title" }).fg

    vim.api.nvim_set_hl(0, "FloatTitle", { fg = float_fg, bg = float_bg })
  end
)
