-- Description -----------------------------------------------------------------------------
--
-- Keymaps configurations.
--
-- -----------------------------------------------------------------------------------------

local M = { }

local map = vim.keymap.set
local ctrl_r = vim.api.nvim_replace_termcodes("<Ctrl-R>", true, false, true)

map("n", "<Esc>", "<Esc>:noh<CR>", { silent = true })

-- Autocompletion --------------------------------------------------------------------------

map(
  "i",
  "<CR>",
  function()
    -- If the completion menu is visible but nothing is selected, close the menu and send
    -- `<CR>`.
    -- If the completion menu is visible with a selection, just add the selection.
    -- Otherwise, just send `<CR>`.
    if vim.fn.pumvisible() == 1 then
      return vim.fn.complete_info().selected == -1 and "<C-y><CR>" or "<C-y>"
    else
      return "<CR>"
    end
  end,
  { expr = true, noremap = true, silent = true }
)

map(
  "i",
  "<Tab>",
  function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
  end,
  { expr = true }
)

map(
  "i",
  "<S-Tab>",
  function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
  end,
  { expr = true }
)

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

-- Text Manipulation -----------------------------------------------------------------------

map(
  "n",
  "<Leader>tf",
  "vy<Esc>93PD<Esc>d92|",
  {
    desc = "Fill with Character Under the Cursor"
  }
)

map(
  "v",
  "<Leader>tf",
  "y<Esc>93PD<Esc>d92|",
  {
    desc = "Fill with Selected Pattern",
  }
)

-- Create a text block given the following input:
--
--     Current line: Fill pattern.
--     Next line: Text to be centered in the block.
map(
  "n",
  "<Leader>tb",
  "<Cmd>set formatoptions-=ro<CR>" ..
  "0v$hy93P\"_D<Esc>\"_d92|j0<Cmd>center<CR>0R<C-R>0<Esc>o<Esc>P<Cmd>right<CR><Esc>khjllv$hykpkyyjpjdd0" ..
  "<Cmd>set formatoptions+=ro",
  {
    desc = "Convert to Block"
  }
)

return M

-- vim:ts=2:sts=2:sw=2:et
