-- Description -----------------------------------------------------------------------------
--
-- Configuration for plugins.
--
-- -----------------------------------------------------------------------------------------

-- MiniMisc --------------------------------------------------------------------------------
--
-- Configure mini.misc since we depend on some functions to load and configure the plugins.

vim.pack.add({ "https://github.com/nvim-mini/mini.misc" })

_G.MiniMisc = require("mini.misc")

MiniMisc.setup()

_G.MiniMisc.later = function(f)
  MiniMisc.safely("later", f)
end

_G.MiniMisc.now = function(f)
  MiniMisc.safely("now", f)
end

_G.MiniMisc.on_event = function(ev, f)
  MiniMisc.safely("event:" .. ev, f)
end

_G.MiniMisc.on_filetype = function(ft, f)
  MiniMisc.safely("filetype:" .. ft, f)
end

-- Plugins ---------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/JuliaEditorSupport/julia-vim",
  "https://github.com/antonk52/filepaths_ls.nvim",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/jake-stewart/multicursor.nvim",
  "https://github.com/juhaku/aiwaku.nvim",
  "https://github.com/lervag/vimtex",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-mini/mini.clue",
  "https://github.com/nvim-mini/mini.cmdline",
  "https://github.com/nvim-mini/mini.completion",
  "https://github.com/nvim-mini/mini.diff",
  "https://github.com/nvim-mini/mini.extra",
  "https://github.com/nvim-mini/mini.files",
  "https://github.com/nvim-mini/mini.hipatterns",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.indentscope",
  "https://github.com/nvim-mini/mini.move",
  "https://github.com/nvim-mini/mini.notify",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.snippets",
  "https://github.com/nvim-mini/mini.splitjoin",
  "https://github.com/nvim-mini/mini.starter",
  "https://github.com/nvim-mini/mini.trailspace",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvimtools/none-ls.nvim",
  "https://github.com/ronisbr/nano-theme.nvim",
  "https://github.com/zbirenbaum/copilot.lua",
})

require("plugins.colorscheme")

require("plugins.builtin")

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
require("plugins.vimtex")

require("plugins.none-ls")

-- Theme Tuning ----------------------------------------------------------------------------

MiniMisc.later(
  function()
    local float_bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg
    local float_fg = vim.api.nvim_get_hl(0, { name = "Title" }).fg

    vim.api.nvim_set_hl(0, "FloatTitle", { fg = float_fg, bg = float_bg })
    vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "FloatTitle" })
    vim.api.nvim_set_hl(0, "MsgArea", { link = "Statusline" })
  end
)
