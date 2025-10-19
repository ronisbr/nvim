-- Description -----------------------------------------------------------------------------
--
-- Keymaps configurations.
--
-- -----------------------------------------------------------------------------------------

function map(mode, lhs, rhs)
  return vim.keymap.set(mode, lhs, rhs, { silent = true })
end

function map(mode, lhs, rhs, desc)
  return vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

function rmap(mode, lhs, rhs, desc)
  return vim.keymap.set(mode, lhs, rhs, { desc = desc, remap = true, silent = true })
end

map("n", "<Esc>", "<Esc>:noh<CR>")

-- Buffers ---------------------------------------------------------------------------------

map("n", "[b", ":bprev<CR>", "Previous Buffer")
map("n", "]b", ":bnext<CR>", "Next Buffer")

-- Tabs ------------------------------------------------------------------------------------

map("n", "[t", ":tabprevious<CR>", "Previous Tab")
map("n", "]t", ":tabnext<CR>", "Next Tab")

-- Text Manipulation -----------------------------------------------------------------------

map(
  "n",
  "<Leader>ta",
  "<Cmd>set lazyredraw<CR>" ..
  "<Cmd>set formatoptions-=ro<CR>" ..
  "mavy`]a<CR><Esc><Cmd>right<CR>k93PDd92|j0whv$hykP`]lDjdd`a" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  "Left Align with Character Under the Cursor"
)

map(
  "v",
  "<Leader>ta",
  "yma<Cmd>set formatoptions-=ro<CR>" ..
  "<Cmd>set lazyredraw<CR>" ..
  "`]a<CR><Esc><Cmd>right<CR>k93pDd92|j0whv$hykP`]lDjdd`a" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  "Left Align with Selected Pattern"
)

map(
  "n",
  "<Leader>tf",
  "<Cmd>set lazyredraw<CR>" ..
  "vy93pDd92|" ..
  "<Cmd>set nolazyredraw<CR>",
  "Fill with Character Under the Cursor"
)

map(
  "v",
  "<Leader>tf",
  "y" ..
  "<Cmd>set lazyredraw<CR>" ..
  "93pDd92|" ..
  "<Cmd>set nolazyredraw<CR>",
  "Fill with Selected Pattern"
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
  "Convert to Block"
)

-- Placeholders <++> -----------------------------------------------------------------------

map("n", "<C-j>", "/<++><CR>v3lc", "Change Next Placeholder")
map("n", "<C-k>", "?<++><CR>v3lc", "Change Previous Placeholder")

rmap("i", "<C-j>", "<Esc><C-j>", "Change Next Placeholder")
rmap("i", "<C-k>", "<Esc><C-k>", "Change Previous Placeholder")

-- Visual Code -----------------------------------------------------------------------------

if vim.g.vscode then
  local vscode = require("vscode")

  -- See:
  --
  --   https://github.com/vscode-neovim/vscode-neovim/issues/1874
  map("n", "gq",  "gq",  "")
  map("v", "gq",  "gq",  "")
  map("n", "gqq", "gqq", "")

  map(
    "n",
    "gf",
    function() vscode.call("seito-openfile.openFileFromText") end,
    "Open File Under the Cursor"
  )
end

-- vim:ts=2:sts=2:sw=2:et
