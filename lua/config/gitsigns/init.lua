-- Plugin configuration: gitsigns.nvim
-- ============================================================================

require('gitsigns').setup {
  numhl = false,
  linehl = false,
  sign_priority = 6,
  status_formatter = nil,
  update_debounce = 200,

  count_chars = {
    [1] = '',
    [2] = '₂',
    [3] = '₃',
    [4] = '₄',
    [5] = '₅',
    [6] = '₆',
    [7] = '₇',
    [8] = '₈',
    [9] = '₉',
    ['+'] = '₊'
  },

  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,
    -- We do not want to define any keymap here.
  },

  signs = {
    add = {
      hl = 'GitSignsAdd',
      linehl = 'GitSignsAddLn',
      numhl = 'GitSignsAddNr',
      text = '+',
    },

    change = {
      hl = 'GitSignsChange',
      linehl = 'GitSignsChangeLn',
      numhl = 'GitSignsChangeNr',
      text = '~'
    },

    delete = {
      hl = 'GitSignsDelete',
      linehl = 'GitSignsDeleteLn',
      numhl = 'GitSignDeleteNr',
      show_count = true,
      text = '_'
    },

    topdelete = {
      hl = 'GitSignsDelete',
      linehl = 'GitSignsDeleteLn',
      numhl = 'GitSignDeleteNr',
      show_count = true,
      text = '‾'
    },

    changedelete = {
      hl = 'GitSignsChange',
      linehl = 'GitSignsChangeLn',
      numhl = 'GitSignsChangeNr',
      show_count = true,
      text = '~'
    }
  },

  watch_index = {
    interval = 1000
  }
}
