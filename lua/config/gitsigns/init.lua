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

  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
    ignore_whitespace = false,
  },

  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,
    -- We do not want to define any keymap here.
  },

  preview_config = {
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },

  signs = {
    add = {
      hl = 'GitSignsAdd',
      linehl = 'GitSignsAddLn',
      numhl = 'GitSignsAddNr',
      text = '▊',
    },

    change = {
      hl = 'GitSignsChange',
      linehl = 'GitSignsChangeLn',
      numhl = 'GitSignsChangeNr',
      text = '▊',
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

  watch_gitdir = {
    interval = 1000,
    follow_files = true
  }
}
