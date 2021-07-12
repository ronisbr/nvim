-- Plugin configuration: Telescope
-- ============================================================================

require('telescope').setup{
  defaults = {
    layout_config = {
      flex = {
        flip_columns = 130
      }
    },
    layout_strategy = 'flex',
    vimgrep_arguments = {
      'rg',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    }
  }
}
