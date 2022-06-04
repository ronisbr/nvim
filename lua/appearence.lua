-- Appearence configuration
-- ============================================================================

-- Theme: base16
-- -----------------------------------------------------------------------------

require('base16-colorscheme').with_config {
    telescope = false,
}

vim.cmd('colorscheme base16-monokai')

-- Theme: doom-one
-- -----------------------------------------------------------------------------

-- require('doom-one').setup({
--   cursor_coloring        = false,
--   enable_treesitter      = true,
--   italic_comments        = true,
--   terminal_colors        = false,
--   transparent_background = false,
--
--   pumblend = {
--     enable = true,
--     transparency_amount = 20,
--   },
--
--   plugins_integrations = {
--     neorg            = true,
--     barbar           = true,
--     bufferline       = true,
--     gitgutter        = true,
--     gitsigns         = true,
--     telescope        = true,
--     neogit           = true,
--     nvim_tree        = true,
--     dashboard        = true,
--     startify         = true,
--     whichkey         = true,
--     indent_blankline = true,
--     vim_illuminate   = true,
--     lspsaga          = true,
--   }
-- })
