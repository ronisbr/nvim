-- General configuration
-- ============================================================================

local indent = 4

-- Global settings
vim.o.clipboard = "unnamedplus"          -- Copy between Vim and OS clipboard
vim.o.completeopt = 'menuone,noselect'   -- Complet options
vim.o.fileencoding = "utf-8"             -- Encode files using UTF-8
vim.o.hidden = true                      -- Enable modified buffers in background
vim.o.ignorecase = true                  -- Ignore case
vim.o.inccommand = 'nosplit'             -- Show effects of a command incrementally
vim.o.joinspaces = false                 -- No double spaces with join after a dot
vim.o.mouse = 'a'                        -- Use mouse in all modes
vim.o.scrolloff = 4                      -- Lines of context
vim.o.shiftround = true                  -- Round indent
vim.o.showmode = false                   -- Do not show the mode in command line
vim.o.sidescrolloff = 8                  -- Columns of context
vim.o.smartcase = true                   -- Don't ignore case with capitals
vim.o.splitbelow = true                  -- Put new windows below current
vim.o.splitright = true                  -- Put new windows right of current
vim.o.termguicolors = true               -- True color support
vim.o.virtualedit = 'block'              -- Set virtualedit for block mode only
vim.o.wildmode = 'list:longest'          -- Command-line completion mode
vim.go.t_Co = "256"                      -- Support 256 colors

-- Buffer-scoped options

-- Window-scoped options
vim.wo.linebreak = true                  -- Break lines only in certain characters
vim.wo.list = true                       -- Show some invisible characters (tabs...)
vim.wo.number = true                     -- Print line number
vim.wo.relativenumber = true             -- Relative line numbers
vim.wo.signcolumn = "yes"                -- Always show the signcolumn
vim.wo.wrap = true                       -- Enable line wrap

-- Those commands must be executed using `vim.cmd` due to:
--     https://github.com/neovim/neovim/issues/12978
vim.cmd [[
set autoindent
set expandtab
set shiftwidth=4
set smartindent
set softtabstop=4
set tabstop=4
set textwidth=80
set colorcolumn=+1
]]

-- Jump to the last position when opening a file.
if vim.fn.has('autocmd') == 1 then
  vim.cmd [[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]]
end
