-- Keybindings
-- =============================================================================

local map = vim.api.nvim_set_keymap

-- Cursor movement
-- -----------------------------------------------------------------------------

map('n', '<up>',   'gk',           {silent = true, noremap = true})
map('n', '<down>', 'gj',           {silent = true, noremap = true})
map('n', '<home>', 'g<Home>',      {silent = true, noremap = true})
map('n', '<end>',  'g<End>',       {silent = true, noremap = true})
map('i', '<up>',   '<C-o>gk',      {silent = true, noremap = true})
map('i', '<down>', '<C-o>gj',      {silent = true, noremap = true})
map('i', '<home>', '<C-o>g<Home>', {silent = true, noremap = true})
map('i', '<end>',  '<C-o>g<End>',  {silent = true, noremap = true})

-- Function keys
-- -----------------------------------------------------------------------------

map('n', '<F5>', ':NvimTreeToggle<CR>', {silent = true})

-- Leader configuration
-- -----------------------------------------------------------------------------

map('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- Prefix: g
-- -----------------------------------------------------------------------------

map('n', 'ga', '<Plug>(EasyAlign)', {})
map('x', 'ga', '<Plug>(EasyAlign)', {})

-- Normal mode (mappings without prefix)
-- -----------------------------------------------------------------------------

-- Clear highlighting on escale in normal mode.
map('n', '<Esc>', ':noh<CR><Esc>', {silent = true, noremap = true})

-- Insert mode
-- -----------------------------------------------------------------------------

-- Remap keys that open floaterm.
map('i', '<F1>', '<ESC><F1>', {noremap = false})
map('i', '<F2>', '<ESC><F2>', {noremap = false})
map('i', '<F3>', '<ESC><F3>', {noremap = false})
map('i', '<F4>', '<ESC><F4>', {noremap = false})

-- Visual mode
-- -----------------------------------------------------------------------------

-- Move selected line / block of text in visual mode
map('x', '<S-Up>',   ':move \'<-2<CR>gv-gv', {noremap = true, silent = true})
map('x', '<S-Down>', ':move \'>+1<CR>gv-gv', {noremap = true, silent = true})

-- Terminal mode
-- -----------------------------------------------------------------------------

map('t', '<Esc>', '<C-\\><C-n>', {noremap = true, silent = true})

-- Lsp saga
-- -----------------------------------------------------------------------------

map('n', '<C-f>', '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<cr>', {noremap = true, silent = true})
map('n', '<C-b>', '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>', {noremap = true, silent = true})

-- WhichKey
-- -----------------------------------------------------------------------------

local wk = require("which-key")

-- Leader (normal mode)
-- --------------------

wk.register({
  ['<leader>'] = {
    -- Window movement
    ['<Up>']    = {'<C-w>k', 'Up window'},
    ['<Down>']  = {'<C-w>j', 'Down window'},
    ['<Left>']  = {'<C-w>h', 'Left window'},
    ['<Right>'] = {'<C-w>l', 'Left window'},

    -- UndoTree
    u = {'UndotreeToggle', 'Undo tree'},

    -- Buffer management
    [','] = {'<cmd>Telescope buffers<cr>', 'List buffers'},
    b = {
      name  = '+buffer',
      c     = {'<cmd>BufferClose<cr>', 'Close buffer'},
      C     = {'<cmd>BufferCloseAllButCurrent<cr>', 'Close all but current'},
      d     = {'<cmd>bdelete<cr>', 'Delete buffer'},
      p     = {'<cmd>BufferPick<cr>', 'Buffer pick'},
      s     = {'<cmd>setlocal spell!<cr>', 'Toggle spell'},
      w     = {'<cmd>StripWhitespace<cr>', 'Strip white space'},
      W     = {'<cmd>ToggleWhitespace<cr>', 'Toggle white space'},
      ['['] = {'<cmd>BufferPrevious<cr>', 'Prev. buffer'},
      [']'] = {'<cmd>BufferNext<cr>', 'Next buffer'}
    },

    -- File management
    f = {
      name = '+file',
      a    = {'<cmd>Telescope live_grep<cr>', 'Find word'},
      b    = {'<cmd>Telescope marks<cr>', 'Bookmarks'},
      f    = {'<cmd>Telescope find_files<cr>', 'Find files'},
      h    = {'<cmd>Telescope oldfiles<cr>', 'History'},
    },

    -- LSP
    l = {
      name = '+lsp',
      a = {'<cmd>lua require("lspsaga.codeaction").code_action()<CR>', 'Code action'},
      d = {'<cmd>lua require("lspsaga.definition").preview_definition()<cr>', 'Preview definition'},
      f = {'<cmd>lua vim.lsp.buf.format({async = true})<cr>', 'Buffer formatting'},
      h = {'<cmd>lua require("lspsaga.finder").lsp_finder()<cr>', 'Lsp Finder'},
      k = {'<cmd>lua require("lspsaga.hover").render_hover_doc()<cr>', 'Hover doc.'},
      l = {'<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<cr>', 'Line diag.'},
      r = {'<cmd>lua require("lspsaga.rename").lsp_rename()<cr>', 'Rename'},
      s = {'<cmd>lua require("lspsaga.signaturehelp").signature_help()<cr>', 'Signature help'},
      ['['] = {'<cmd>lua require("lspsaga.diagnostic").goto_prev()<cr>', 'Prev. diag.'},
      [']'] = {'<cmd>lua require("lspsaga.diagnostic").goto_next()<cr>', 'Next diag.'},
    },

    -- Git
    g = {
      name  = '+git',
      g     = {'<cmd>Git<cr>', 'Fugitive'},
      s     = {'<cmd>Gitsigns stage_hunk<cr>', 'Stage hunk'},
      u     = {'<cmd>Gitsigns undo_stage_hunk<cr>', 'Undo stage hunk'},
      r     = {'<cmd>Gitsigns reset_hunk<cr>', 'Reset hunk'},
      R     = {'<cmd>Gitsigns reset_buffer<cr>', 'Reset buffer'},
      p     = {'<cmd>Gitsigns preview_hunk<cr>', 'Preview hunk'},
      b     = {'<cmd>lua require"gitsigns".blame_line{full=true}<cr>', 'Blame line'},
      S     = {'<cmd>Gitsigns stage_buffer<cr>', 'Stage buffer'},
      U     = {'<cmd>Gitsigns reset_buffer_index<cr>', 'Reset buffer index'},
      [']'] = {'<cmd>Gitsigns next_hunk<cr>', 'Next hunk'},
      ['['] = {'<cmd>Gitsigns prev_hunk<cr>', 'Next hunk'},
    },

    -- Bookmark
    m = {
      name = '+bookmark',
      m    = {'<cmd>BookmarkToggle<cr>', 'Toogle bookmark'},
      i    = {'<cmd>BookmarkAnnotate<cr>', 'Annotate bookmark'},
      n    = {'<cmd>BookmarkNext<cr>', 'Next bookmark'},
      p    = {'<cmd>BookmarkPrev<cr>', 'Prev. bookmark'},
    },

    -- Session
    s = {
      name = '+session',
      l    = {'<cmd><C-u>SessionLoad<cr>', 'Load session'},
      s    = {'<cmd><C-u>SessionSave<cr>', 'Save session'},
    },

    -- Text manipulation
    t = {
      name = '+text',
      c    = {
        name  = '+align comments',
        l     = {"<cmd>call v:lua.require('utils/align_comment').align_comments('l')<cr>", 'To the left'},
        c     = {"<cmd>call v:lua.require('utils/align_comment').align_comments('c')<cr>", 'To the center'},
        r     = {"<cmd>call v:lua.require('utils/align_comment').align_comments('r')<cr>", 'To the right'},
        ['.'] = {
          name = '+with dot',
          l    = {"<cmd>call v:lua.require('utils/align_comment').align_comments_with_char('.', 'l')<cr>", 'To the left'},
          c    = {"<cmd>call v:lua.require('utils/align_comment').align_comments_with_char('.', 'c')<cr>", 'To the center'},
          r    = {"<cmd>call v:lua.require('utils/align_comment').align_comments_with_char('.', 'r')<cr>", 'To the right'},
        },
      },
      ['f']    = {
        ['name'] = '+fill',
        ['f']    = {"<cmd>call v:lua.require('utils/fill_text').fill_with_cursor_character()<cr>", 'Fill with cursor char'},
        ['p']    = {"<cmd>call v:lua.require('utils/fill_text').fill_with_input()<cr>", 'Fill with input pattern'}
      }
    },

   -- Window manipulation
    w = {
      name  = '+window',
      ['-'] = {'<cmd>split<cr>', 'Horiz. window'},
      ['|'] = {'<cmd>vsplit<cr>', 'Vert. window'},
      c     = {'<cmd>close<cr>', 'Close window'},
      k     = {'<cmd><C-w>k<cr>', 'Up window'},
      j     = {'<cmd><C-w>j<cr>', 'Down window'},
      h     = {'<cmd><C-w>h<cr>', 'Left window'},
      l     = {'<cmd><C-w>l<cr>', 'Right window'},
    }
  }
})

-- Leader (visual mode)
-- --------------------

wk.register({
  ['<leader>'] = {
    -- LSP
    l = {
      name = '+lsp',
      a = {'<cmd>lua require("lspsaga.codeaction").code_action()<CR>', 'Code action'},
      c = {'<cmd>lua require("lspsaga.diagnostic").show_cursor_diagnostics()<cr>', 'Cursor diag.'},
      d = {'<cmd>lua require("lspsaga.provider").preview_definition()<cr>', 'Preview definition'},
      f = {'<cmd>lua vim.lsp.buf.formatting()<cr>', 'Buffer formatting'},
      h = {'<cmd>lua require("lspsaga.provider").lsp_finder()<cr>', 'Lsp Finder'},
      k = {'<cmd>lua require("lspsaga.hover").render_hover_doc()<cr>', 'Hover doc.'},
      l = {'<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<cr>', 'Line diag.'},
      r = {'<cmd>lua require("lspsaga.rename").rename()<cr>', 'Rename'},
      s = {'<cmd>lua require("lspsaga.signaturehelp").signature_help()<cr>', 'Signature help'},
      ['['] = {'<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<cr>', 'Prev. diag.'},
      [']'] = {'<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<cr>', 'Next diag.'},
    },

    -- Git
    g = {
      name = '+git',
      s    = {':Gitsigns stage_hunk<cr>', 'Stage hunk'},
      r    = {':Gitsigns reset_hunk<cr>', 'Reset hunk'},
    },

    -- Text manipulation
    t = {
      name = '+text',
      c    = {
        name  = '+align comments',
        l     = {"<cmd>call v:lua.require('utils/align_comment').align_comments('l')<cr>", 'To the left'},
        c     = {"<cmd>call v:lua.require('utils/align_comment').align_comments('c')<cr>", 'To the center'},
        r     = {"<cmd>call v:lua.require('utils/align_comment').align_comments('r')<cr>", 'To the right'},
        ['.'] = {
          name = '+with dot',
          l    = {"<cmd>call v:lua.require('utils/align_comment').align_comments_with_char('.', 'l')<cr>", 'To the left'},
          c    = {"<cmd>call v:lua.require('utils/align_comment').align_comments_with_char('.', 'c')<cr>", 'To the center'},
          r    = {"<cmd>call v:lua.require('utils/align_comment').align_comments_with_char('.', 'r')<cr>", 'To the right'},
        },
      },
      ['f']    = {
        ['name'] = '+fill',
        ['f']    = {"<cmd>call v:lua.require('utils/fill_text').fill_with_cursor_character()<cr>", 'Fill with cursor char'},
        ['p']    = {"<cmd>call v:lua.require('utils/fill_text').fill_with_input()<cr>", 'Fill with input pattern'}
      }
    },
  }
}, {
  mode = 'v',
})

-- s
-- -----------------------------------------------------------------------------

wk.register({
  s = {
    name = 'Hop',
    l    = {'<cmd>HopLine<cr>', 'Hop line'},
    s    = {'<cmd>HopChar2<cr>', 'Hop char 2'},
    w    = {'<cmd>HopWord<cr>', 'Hop word'},
  }
})
