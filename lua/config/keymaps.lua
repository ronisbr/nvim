-- Keymaps are automatically loaded on the VeryLazy event.
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set
local ls = require("luasnip")
local wk = require("which-key")

wk.register(
  {
    o = { name = "open" },
    r = {
      name = "ronisbr",
      c = {
        name = "comments",
        {
          a = {
            name = "align"
          }
        }
      },
      f = { name = "fill" }
    },
    t = { name = "tables" },
    z = { name = "zk" }
  },
  { prefix = "<leader>" }
)

wk.register(
  {
    r = {
      name = "ronisbr",
      c = {
        name = "comments",
        {
          a = {
            name = "align"
          }
        }
      },
    }
  },
  { prefix = "<leader>", mode = "v" }
)

-- File ------------------------------------------------------------------------------------

-- Save file.
map("n", "<leader>fs", ":w<cr>", { desc = "Save File", silent = true })

-- Open file browser.
map("n", "<leader>.", ":Telescope file_browser path=%:p:h select_buffer=true<cr>", {
  desc = "Open File Explorer",
  silent = true
})

-- Line Movements and Actions --------------------------------------------------------------

-- Delete the highlighted section without replacing the default register.
map("x", "<localleader>d", '"_d')

-- Keep cursor position when performing half-jumps.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor position when joining.
map("n", "J", "mzJ`z")

-- Paste over highlighted text preserving the default register.
map("x", "<localleader>p", '"_dP')

-- Window Manipulation ---------------------------------------------------------------------

map("n", "<leader><Up>",    "<C-w>k", { desc = "Up Window" })
map("n", "<leader><Down>",  "<C-w>j", { desc = "Down Window" })
map("n", "<leader><Left>",  "<C-w>h", { desc = "Left Window" })
map("n", "<leader><Right>", "<C-w>l", { desc = "Right Window" })

--------------------------------------------------------------------------------------------
--                                        Plugins                                         --
--------------------------------------------------------------------------------------------

-- floaterm --------------------------------------------------------------------------------

map("n", "<leader>ot", "<cmd>FloatermToggle<cr>", { desc = "Toogle Floatterm" })
map({"i", "n", "v"}, "<F2>", "<esc><cmd>FloatermNew<cr>", { desc = "New Floatterm" })
map({"i", "n", "v"}, "<F5>", "<esc><cmd>FloatermToggle<cr>", { desc = "Toggle Floatterm" })
map("t", "<F2>", "<C-\\><C-n><cmd>FloatermNew<cr>", { desc = "New Floatterm" })
map("t", "<F3>", "<C-\\><C-n><cmd>FloatermPrev<cr>", { desc = "Previous Floatterm" })
map("t", "<F4>", "<C-\\><C-n><cmd>FloatermNext<cr>", { desc = "Next Floatterm" })
map("t", "<F5>", "<C-\\><C-n><cmd>FloatermToggle<cr>", { desc = "Toggle Floatterm" })

-- luasnip ---------------------------------------------------------------------------------

map({"i", "s"}, "<C-j>", function() ls.jump( 1) end, { silent = true })
map({"i", "s"}, "<C-k>", function() ls.jump(-1) end, { silent = true })
map(
  {"i", "s"},
  "<C-e>",
  function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end,
  { silent = true }
)

-- Neogit ----------------------------------------------------------------------------------

map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })

-- Neovide ---------------------------------------------------------------------------------

if vim.g.neovide then
  map("n", "<D-s>", ":w<CR>")      -- ................................................. Save
  map("v", "<D-c>", '"+y')         -- ................................................. Copy
  map("n", "<D-v>", '"+P')         -- .................................... Paste normal mode
  map("v", "<D-v>", '"+P')         -- .................................... Paste visual mode
  map("c", "<D-v>", "<C-R>+")      -- ................................... Paste command mode
  map("i", "<D-v>", '<ESC>l"+Pli') -- .................................... Paste insert mode
end

-- Allow clipboard copy paste in neovim.
map("",  "<D-v>", "+p<CR>", { noremap = true, silent = true })
map("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
map("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
map("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- ronisbr ---------------------------------------------------------------------------------

-- Comment Manipulation --

map(
  { "n", "v" },
  "<leader>rcac",
  '<cmd>lua require("misc.comment_manipulation").align_comments("c")<cr>',
  { desc = "Align Comments to the Center"}
)

map(
  { "n", "v" },
  "<leader>rcar",
  '<cmd>lua require("misc.comment_manipulation").align_comments("r")<cr>',
  { desc = "Align Comments to the Right"}
)

-- Text Manipulation --

map(
  "n",
  "<leader>rfc",
  '<cmd>lua require("misc.text_manipulation").fill_with_cursor_character()<cr>',
  { desc = "Fill with Cursor"}
)

map(
  "n",
  "<leader>rfi",
  '<cmd>lua require("misc.text_manipulation").fill_with_input()<cr>',
  { desc = "Fill with Input" }
)

-- whitespace.nvim -------------------------------------------------------------------------

map(
  "n",
  "<leader>cw",
  require("whitespace-nvim").trim
)

-- zk-nvim ---------------------------------------------------------------------------------

-- Create a new zk note.
local function zk_new_note()
  vim.ui.select(
    {
      "Diário",
      "Notas",
      "Trabalho"
    }, {
      prompt = "Select the directory:",
    },
    function(choice)
      local cmd = require("zk.commands")

      if choice == "Diário" then
        cmd.get("ZkNew")({ dir = "Diário" })
      elseif choice == "Notas" then
        local title = vim.fn.input("Note Title: ")
        cmd.get("ZkNew")({ dir = "Notas", title = title })
      elseif choice == "Trabalho" then
        local title = vim.fn.input("Note Title: ")
        cmd.get("ZkNew")({ dir = "Trabalho", title = title })
      end
    end)
end

map(
  "n",
  "<leader>zn",
  zk_new_note,
  { desc = "New Note", noremap = true, silent = true }
)

map(
  "n",
  "<leader>zf",
  '<cmd>ZkNotes { sort = { "modified" } }<cr>',
  { desc = "Find Notes", noremap = true, silent = true }
)

map(
  "n",
  "<leader>zd",
  "<cmd>Telescope file_browser path=~/Nextcloud/zk<cr>",
  { desc = "Open zk directory", noremap = true }
)

map(
  "n",
  "<leader>zt",
  "<cmd>ZkTags<cr>",
  { desc = "Open zk directory", noremap = true }
)
