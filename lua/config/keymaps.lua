-- Description -----------------------------------------------------------------------------
--
-- Keymaps configurations.
--
-- -----------------------------------------------------------------------------------------

local M = { }

local map = vim.keymap.set

map("n", "<Esc>", "<Esc>:noh<CR>", { silent = true })

-- Buffers ---------------------------------------------------------------------------------

map(
  "n",
  "[b",
  ":bprev<CR>",
  {
    desc = "Previous Buffer",
    silent = true
  }
)

map(
  "n",
  "]b",
  ":bnext<CR>",
  {
    desc = "Next Buffer",
    silent = true
  }
)

-- Tabs ------------------------------------------------------------------------------------

map(
  "n",
  "[t",
  ":tabprevious<CR>",
  {
    desc = "Previous Tab",
    silent = true
  }
)

map(
  "n",
  "]t",
  ":tabnext<CR>",
  {
    desc = "Next Tab",
    silent = true
  }
)

-- Terminal --------------------------------------------------------------------------------

-- map(
--   "t",
--   "<Esc>",
--   "<C-\\><C-n>",
--   { silent = true }
-- )

-- Text Manipulation -----------------------------------------------------------------------

map(
  "n",
  "<Leader>ta",
  "<Cmd>set lazyredraw<CR>" ..
  "<Cmd>set formatoptions-=ro<CR>" ..
  "mavy`]a<CR><Esc><Cmd>right<CR>k93PDd92|j0whv$hykP`]lDjdd`a" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  {
    desc = "Left Align with Character Under the Cursor",
    silent = true
  }
)

map(
  "v",
  "<Leader>ta",
  "yma<Cmd>set formatoptions-=ro<CR>" ..
  "<Cmd>set lazyredraw<CR>" ..
  "`]a<CR><Esc><Cmd>right<CR>k93pDd92|j0whv$hykP`]lDjdd`a" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  {
    desc = "Left Align with Selected Pattern",
    silent = true
  }
)

map(
  "n",
  "<Leader>tf",
  "<Cmd>set lazyredraw<CR>" ..
  "vy93pDd92|" ..
  "<Cmd>set nolazyredraw<CR>",
  {
    desc = "Fill with Character Under the Cursor",
    silent = true
  }
)

map(
  "v",
  "<Leader>tf",
  "y" ..
  "<Cmd>set lazyredraw<CR>" ..
  "93pDd92|" ..
  "<Cmd>set nolazyredraw<CR>",
  {
    desc = "Fill with Selected Pattern",
    silent = true
  }
)

-- Create a text block given the following input:
--
--     Current line: Fill pattern.
--     Next line: Text to be centered in the block.
map(
  "n",
  "<Leader>tb",
  "<Cmd>set lazyredraw<CR>" ..
  "<Cmd>set formatoptions-=ro<CR>" ..
  "0v$hy93P\"_D\"_d92|j0<Cmd>center<CR>0R<C-R>0<Esc>o<Esc>P<Cmd>right<CR>khjllv$hykpkyyjpjdd0" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  {
    desc = "Convert to Block",
    silent = true
  }
)

-- Placeholders <++> -----------------------------------------------------------------------

map(
  "n",
  "<C-j>",
  "/<++><CR>v3lc",
  {
    desc = "Change Next Placeholder",
    silent = true,
  }
)

map(
  "i",
  "<C-j>",
  "<Esc><C-j>",
  {
    desc = "Change Next Placeholder",
    remap = true,
    silent = true
  }
)

map(
  "n",
  "<C-k>",
  "?<++><CR>v3lc",
  {
    desc = "Change Previous Placeholder",
    silent = true
  }
)

map(
  "i",
  "<C-k>",
  "<Esc><C-k>",
  {
    desc = "Change Previous Placeholder",
    remap = true,
    silent = true
  }
)

return M

-- vim:ts=2:sts=2:sw=2:et
