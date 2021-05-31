-- Plugin configuration: vimtex
-- ============================================================================

vim.g.tex_flavor = "latex"
vim.g.vimtex_compiler_progname = 'nvr'
vim.g.vimtex_compiler_latexmk = {
  continuous = 0
}
vim.g.vimtex_quickfix_mode = 2
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_view_general_options = '-r @line @pdf @tex'
vim.g.vimtex_view_general_viewer = '/Applications/Skim.app/Contents/SharedSupport/displayline'
vim.g.vimtex_view_method = 'skim'
