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

-- Prefix: <leader>
-- -----------------------------------------------------------------------------

map('n', '<Leader>', [[:<C-u>WhichKey "<space>"<CR>]], {silent = true})
map('v', '<Leader>', [[:<C-u>WhichKeyVisual "<space>"<CR>]], {silent = true})
vim.call('which_key#register', '<Space>', 'g:which_key_leader')

map('n', '<Leader><Up>', '<C-w>k', {silent = true})
map('n', '<Leader><Down>', '<C-w>j', {silent = true})
map('n', '<Leader><Left>', '<C-w>h', {silent = true})
map('n', '<Leader><Right>', '<C-w>l', {silent = true})
map('n', '<Leader>sl', ':<C-u>SessionLoad<CR>', {})
map('n', '<Leader>ss', ':<C-u>SessionSave<CR>', {})

-- Prefix: g
-- -----------------------------------------------------------------------------

map('n', 'ga', '<Plug>(EasyAlign)', {})
map('x', 'ga', '<Plug>(EasyAlign)', {})

-- Prefix: s
-- -----------------------------------------------------------------------------

map('n', 's', [[:<C-u>WhichKey "s"<CR>]], {silent = true})
vim.call('which_key#register', 's', 'g:which_key_s')

map('n', 'sl', ':HopLine<CR>', {silent = true})
map('n', 'ss', ':HopChar2<CR>', {silent = true})
map('n', 'sw', ':HopWord<CR>',  {silent = true})

-- Normal mode (mappings without prefix)
-- -----------------------------------------------------------------------------

-- Clear highlighting on escale in normal mode.
map('n', '<Esc>', ':noh<CR><Esc>', {silent = true, noremap = true})

-- Insert mode
-- -----------------------------------------------------------------------------

-- Call auto-complete with `<C-n>` and `<C-p>`.
map('i', '<C-n>', 'compe#complete()', {noremap = true, expr = true})
map('i', '<C-p>', 'compe#complete()', {noremap = true, expr = true})

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

-- WhichKey
-- -----------------------------------------------------------------------------

vim.g.which_key_leader = {
  ['name']    = '',
  [' ']       = {':Telescope find_files', 'File manager'},
  [',']       = {':Telescope buffers', 'Show buffers'},
  ['<Up>']    = 'Up window',
  ['<Down>']  = 'Down window',
  ['<Left>']  = 'Left window',
  ['<Right>'] = 'Right window',
  ['u']       = {'UndotreeToggle', 'Undo tree'},

  -- Submenus
  -- ---------------------------------------------------------------------------

  -- Buffer
  ['b'] = {
    ['name'] = '+buffer',
    ['c']    = {'BufferClose', 'Close buffer'},
    ['C']    = {'BufferCloseAllButCurrent', 'Close all but current'},
    ['d']    = {'bdelete', 'Delete buffer'},
    ['p']    = {'BufferPick', 'Buffer pick'},
    ['s']    = {':setlocal spell!', 'Toggle spell'},
    ['w']    = {':StripWhitespace', 'Strip white space'},
    ['W']    = {':ToggleWhitespace', 'Toggle white space'},
    ['[']    = {'BufferPrevious', 'Prev. buffer'},
    [']']    = {'BufferNext', 'Next buffer'}
  },

  -- File
  ['f'] = {
    ['name'] = '+file',
    ['a']    = {':Telescope live_grep', 'Find word'},
    ['b']    = {':Telescope marks', 'Bookmarks'},
    ['f']    = {':Telescope find_files', 'Find files'},
    ['h']    = {':Telescope oldfiles', 'History'},
  },

  -- Git
  ['g'] = {
    ['name'] = '+git',
    ['g']    = {'Git', 'Fugitive'},
  },

  -- Bookmark
  ['m'] = {
    ['name'] = '+bookmark',
    ['m']    = {':BookmarkToggle', 'Toogle bookmark'},
    ['i']    = {':BookmarkAnnotate', 'Annotate bookmark'},
    ['n']    = {':BookmarkNext', 'Next bookmark'},
    ['p']    = {':BookmarkPrev', 'Prev. bookmark'},
  },

  -- Session
  ['s'] = {
    ['name'] = '+session',
    ['l']    = 'Load session',
    ['s']    = 'Save session'
  },

  ['t'] = {
    ['name'] = '+text',
    ['c']    = {
      ['name'] = '+align comments',
      ['l']    = {":call v:lua.require('utils/align_comment').align_comments('l')", 'To the left'},
      ['c']    = {":call v:lua.require('utils/align_comment').align_comments('c')", 'To the center'},
      ['r']    = {":call v:lua.require('utils/align_comment').align_comments('r')", 'To the right'},
      ['.']    = {
        ['name'] = '+with dot',
        ['l']    = {":call v:lua.require('utils/align_comment').align_comments_with_char('.', 'l')", 'To the left'},
        ['c']    = {":call v:lua.require('utils/align_comment').align_comments_with_char('.', 'c')", 'To the center'},
        ['r']    = {":call v:lua.require('utils/align_comment').align_comments_with_char('.', 'r')", 'To the right'},
      },
    },
    ['f']    = {
      ['name'] = '+fill',
      ['f']    = {":call v:lua.require('utils/fill_text').fill_with_cursor_character()", 'Fill with cursor char'},
      ['p']    = {":call v:lua.require('utils/fill_text').fill_with_input()", 'Fill with input pattern'}
    }
  },

  -- Window
  ['w'] = {
    ['name'] = '+window',
    ['-']    = {'split', 'Horiz. window'},
    ['|']    = {'vsplit', 'Vert. window'},
    ['c']    = {'close', 'Close window'},
    ['k']    = {'<C-w>k', 'Up window'},
    ['j']    = {'<C-w>j', 'Down window'},
    ['h']    = {'<C-w>h', 'Left window'},
    ['l']    = {'<C-w>l', 'Right window'},
  }
}

vim.g.which_key_s = {
  ['name'] = 'Hop',
  ['l']    = 'Hop line',
  ['s']    = 'Hop char 2',
  ['w']    = 'Hop word'
}
