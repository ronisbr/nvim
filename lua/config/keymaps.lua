-- Keymaps are automatically loaded on the VeryLazy event.
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local wk = require("which-key")

wk.register({
  o = { name = "open" },
  r = { name = "ronisbr",
    f = { name = "fill" }
  }
}, { prefix = "<leader>" })

-- floaterm --------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>ot", "<cmd>FloatermToggle<cr>", { desc = "Toogle Floatterm" })
vim.keymap.set({"i", "n", "v"}, "<F2>", "<esc><cmd>FloatermNew<cr>", { desc = "New Floatterm" })
vim.keymap.set({"i", "n", "v"}, "<F5>", "<esc><cmd>FloatermToggle<cr>", { desc = "Toggle Floatterm" })
vim.keymap.set("t", "<F2>", "<C-\\><C-n><cmd>FloatermNew<cr>", { desc = "New Floatterm" })
vim.keymap.set("t", "<F3>", "<C-\\><C-n><cmd>FloatermPrev<cr>", { desc = "Previous Floatterm" })
vim.keymap.set("t", "<F4>", "<C-\\><C-n><cmd>FloatermNext<cr>", { desc = "Next Floatterm" })
vim.keymap.set("t", "<F5>", "<C-\\><C-n><cmd>FloatermToggle<cr>", { desc = "Toggle Floatterm" })

-- Neogit ----------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })

-- Neovide ---------------------------------------------------------------------------------

if vim.g.neovide then
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim.
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>",  { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- Text Manipulation -----------------------------------------------------------------------

vim.api.nvim_set_keymap(
  "n",
  "<leader>rfc",
  '<cmd>lua require("misc.text_manipulation").fill_with_cursor_character()<cr>',
  { desc = "Fill with Cursor"}
)

vim.api.nvim_set_keymap(
  "n", 
  "<leader>rfi",
  '<cmd>lua require("misc.text_manipulation").fill_with_input()<cr>', 
  { desc = "Fill with Input" }
)