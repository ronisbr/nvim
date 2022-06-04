-- Plugin configuration: lualine
-- ============================================================================

require('lualine').setup({
  options = {
    component_separators = { left = '/', right = '/' },
    disabled_filetypes = {
      'alpha',
      'NvimTree',
    },
    section_separators = { left = ' ', right = ' ' }
  }
})
